class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Kaminari pagination config
  paginates_per 5

  # Can vote for Funs
  acts_as_voter

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :name,
                  :password, :password_confirmation, :remember_me,
                  :avatar, :remote_avatar_url, :avatar_cache, :remove_avatar,
                  :setting_attributes, :require_valid_email
  attr_accessible :role_id, as: :admin
  attr_accessor :require_valid_email

  validates_confirmation_of :password

  # Avatar uploader
  mount_uploader :avatar, AvatarUploader

  # Associations
  belongs_to :role
  has_many :funs
  has_one :stat

  def funs_with_reposts
    Fun.unscoped.where( user_id: id )
  end

  # User settings
  has_one :setting
  accepts_nested_attributes_for :setting, allow_destroy: true

    # Followers and followed
  has_many :user_relationships, foreign_key: 'follower_id', dependent: :destroy
  has_many :reverse_user_relationships, foreign_key: 'followed_id', class_name: 'UserRelationship', dependent: :destroy

  has_many :followed_users, through: :user_relationships, source: :followed
  has_many :followers, through: :reverse_user_relationships, source: :follower

  # Authorization services (FB, VK, TW)
  has_many :identities

  # Validation rules

  validates :email, uniqueness: true, format: { with: email_regexp }, if: :email_required?
  validates :login, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9_-]*\Z/i }, length: { minimum: 3 }

  # Set default role
  before_create :set_default_role

  after_create { create_setting if setting.nil? }
  after_create { create_stat if stat.nil? }

  scope :online, lambda{ where('last_response_at > ?', 10.minutes.ago) }

  def to_jq_upload
    { thumb_url: avatar.img.url }.to_json
  end

  def info_to_json
    {
        login: login,
        avatar_path: avatar.img.small.url,
    }
  end

  # Check user state
  def online?
    ! last_response_at.nil? && last_response_at  > 10.minutes.ago
  end

  # Compare user role
  def role?(role)
    self.role.try(:name) == role.to_s
  end

  # Get user ids, which user follow
  def following_ids
    @following_ids ||= followed_users.pluck('users.id')
    end

  def followers_ids
    @followers_ids ||= followers.pluck('users.id')
  end

  # Check if user already followed
  def follow?(other_user)
    other_user.id.in? following_ids
  end

  def following_list
    User.where(id: self.following_ids).joins(:stat).includes(:stat)
  end

  def followers_list
    User.where(id: self.followers_ids).joins(:stat).includes(:stat)
  end

  # Follow user
  def follow!(other_user)
    user_relationships.create!(followed_id: other_user.id)
  end

  # Unfollow user
  def unfollow!(other_user)
    find = user_relationships.find_by_followed_id(other_user.id)
    find.destroy unless find.nil?
  end

  # methods witch recount stats
  def count_funs(range)
    range.nil? ? funs.count : funs.where(created_at: range).count
  end

  def count_followers(range)
    range.nil? ? followers.count : followers.where(created_at: range).count
  end

  def count_votes(range)
    @fun_ids ||= Fun.unscoped { Fun.where(user_id: id) }.pluck(:id)
    if range.nil?
      ActsAsVotable::Vote.where(votable_type: Fun, voter_type: User, votable_id: @fun_ids).count
    else
      ActsAsVotable::Vote.where(created_at: range, votable_type: Fun, voter_type: User, votable_id: @fun_ids).count
    end
  end

  def count_reposts(range)
    range.nil? ? reposts.count : reposts.where(created_at: range).count
  end

  # Get user reposts
  def reposts
    Fun.unscoped { Fun.where('parent_id IS NOT NULL').where(owner_id: id) }
  end

  # Get funs ids which user reposted
  def reposted_ids
    @reposted_ids ||= Fun.unscoped { funs.where('parent_id IS NOT NULL').pluck(:parent_id) }
  end

  # Check if user already reposted
  def reposted?(fun)
    fun.id.in? reposted_ids
  end

  # Get funs ids which user voted
  def voted_ids
    @voted_ids ||= votes.where(votable_type: Fun).pluck(:votable_id)
  end

  # Check if user already voted
  def voted?(fun)
    fun.id.in? voted_ids
  end

  # User feeds
  def feed
    Fun.unscoped.from_users_followed_by(self)
  end

  # Insert login param in to URL
  def to_param
    login
  end

  # Get funs_id which user voted
  def get_voted_ids(created_at)
    funs = votes.where(votable_type: Fun)
    funs.where(created_at: created_at) unless created_at.blank?
    funs.pluck(:votable_id)
  end

  def update_profile(params={})
    params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password_confirmation)
    end

    result = update_attributes(params)
    clean_up_passwords
    result
  end

  def binded?(provider)
    @providers ||= identities.pluck(:provider)
    provider.to_s.in? @providers
  end

  class << self

    def sort_column(column)
      %w(funs votes reposts followers created_at).include?(column) ? column : 'followers'
    end

    def sort_direction(direction)
      %w(asc desc).include?(direction) ? direction : 'desc'
    end

    def sort_interval(interval)
      %w(day week month all).include?(interval) ? interval : 'week'
    end

    def sorting(column, direction, interval)
      order("#{column != 'created_at' ? interval + '_' : ''}#{column} #{direction}, `users`.id #{direction}")
    end

    # Create user from oAuth data
    def create_with_omniauth(data)
      providers = Devise.omniauth_providers
      if data.provider.to_sym.in? providers
        send("create_" + data.provider + "_user", data)
      else
        User.new
      end
    end

    private

    def create_facebook_user(data)
      user = User.find_by_email(data.info.email)
      if user.present?
        user
      else
        user = create(email: data.info.email, login: get_available_login(data), remote_avatar_url: data.info.image, password: Devise.friendly_token[0,10])
        user.create_setting(fb_link: data.info.urls.Facebook) # todo get sex from gender and birthday
        user
      end
    end

    def create_vkontakte_user(data)
      user = User.create(login: get_available_login(data), remote_avatar_url: data.extra.raw_info.photo_big, password: Devise.friendly_token[0,10], require_valid_email: true)
      user.create_setting(sex: data.extra.raw_info.sex, vk_link: data.info.urls.Vkontakte) # todo get valid sex and birthday
      user
    end

    def create_twitter_user(data)
      user = User.create(login: get_available_login(data), remote_avatar_url: data.info.image, password: Devise.friendly_token[0,10], require_valid_email: true)
      user.create_setting(location: data.info.location, tw_link: data.info.urls.Twitter, info: data.info.description)
      user
    end

    # Prepare variants for login from auth data
    def variants_of_login(data)
      case data.provider
        when "facebook"
          [data.info.nickname, data.info.email.split("@").first, data.info.first_name, data.info.last_name, data.info.name]
        when "vkontakte"
          [data.info.nickname, data.extra.raw_info.screen_name, data.info.first_name, data.info.last_name, data.info.name]
        when "twitter"
          [data.info.nickname, data.info.name]
        else
          []
      end
    end

    # Create available login from variants
    def get_available_login(data)
      login = data.provider.first + data.uid.to_s
      variants = variants_of_login(data).map { |i| i.to_s.parameterize if i.to_s.parameterize.present? }.compact
      variants.concat(variants.map { |i| i + rand(9999).to_s }) if variants.any?
      if variants.any?
        used = User.where(:login => variants).pluck(:login)
        variants = variants - used
        login = variants.first unless variants.first.nil?
      end
      login
    end
  end

  protected
  # override method from Devise::Models::Validatable
  # if recipe added from vkontakte application return false, else return true
  def email_required?
    require_valid_email.nil?
  end

  private
  def set_default_role
    self.role ||= Role.find_by_name(:user)
  end
end