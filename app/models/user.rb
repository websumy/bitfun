class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Can vote for Funs
  acts_as_voter

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :name,
                  :password, :password_confirmation, :remember_me,
                  :avatar, :remote_avatar_url, :avatar_cache, :remove_avatar,
                  :user_setting_attributes, :require_valid_email
  attr_accessible :role_id, as: :admin
  attr_accessor :require_valid_email

  # Avatar uploader
  mount_uploader :avatar, AvatarUploader

  # Associations
  belongs_to :role
  has_many :funs

  # User settings
  has_one :user_setting
  accepts_nested_attributes_for :user_setting, :allow_destroy => true

  # Followers and followed
  has_many :user_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_user_relationships, foreign_key: "followed_id", class_name: "UserRelationship", dependent: :destroy

  has_many :followed_users, through: :user_relationships, source: :followed
  has_many :followers, through: :reverse_user_relationships, source: :follower

  # Authorization services (FB, VK, TW)
  has_many :identities

  # Validation rules
  validates :login, presence: true, uniqueness: true

  # Set default role
  before_create :set_default_role

  # Compare user role
  def role?(role)
    self.role.try(:name) == role.to_s
  end

  def following?(other_user)
    user_relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    user_relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    user_relationships.find_by_followed_id(other_user.id).destroy
  end

  # User feeds
  def feed
    Fun.from_users_followed_by(self)
  end

  # Insert login param in to URL
  def to_param
    login
  end

  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:current_password)
      self.update_without_password(params)
    else
      self.verify_password_and_update(params)
    end
  end

  def update_without_password(params={})

    params.delete(:password)
    params.delete(:password_confirmation)
    result = update_attributes(params)
    clean_up_passwords
    result
  end

  def verify_password_and_update(params)
    #devises' update_with_password
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if valid_password?(current_password)
               update_attributes(params)
             else
               self.attributes = params
               self.valid?
               self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               false
             end

    clean_up_passwords
    result
  end

  # Create available login from auth data
  def self.get_available_login(auth)
    case auth.provider
      when "facebook"
        args = [auth.info.nickname, auth.info.email.split("@").first, auth.info.first_name, auth.info.last_name, auth.info.name]
      when "vkontakte"
        args = [auth.info.nickname, auth.extra.raw_info.screen_name, auth.info.first_name, auth.info.last_name, auth.info.name]
      when "twitter"
        args = [auth.info.nickname, auth.info.name]
      else
        args = []
    end
    login = auth.provider.first + auth.uid.to_s
    options = args.map { |i| i.to_s.parameterize if i.to_s.parameterize.present? }.compact
     options = options + options.map { |i| i + rand(9999).to_s } if options.any?
    if options.any?
      check = User.select(:login).where(:login => options).map(&:login)
      available = options - check
      login = available.first unless available.first.nil?
    end
    login
  end

  # Create user from oAuth data
  def self.create_with_omniauth auth
    case auth.provider
      when "facebook"
        user = User.find_all_by_email(auth.info.email)
        unless user.present?
          user = create(email: auth.info.email, login: get_available_login(auth), remote_avatar_url: auth.info.image, password: Devise.friendly_token[0,10])
          user.create_user_setting(fb_link: auth.info.urls.Facebook) # todo get sex from gender and birthday
          user
        end
      when "vkontakte"
        user = User.create(login: get_available_login(auth), remote_avatar_url: auth.extra.raw_info.photo_big, password: Devise.friendly_token[0,10], require_valid_email: true)
        user.create_user_setting(sex: auth.extra.raw_info.sex, vk_link: auth.info.urls.Vkontakte) # todo get valid sex and birthday
        user
      when "twitter"
        user = User.create(login: get_available_login(auth), remote_avatar_url: auth.info.image, password: Devise.friendly_token[0,10], require_valid_email: true)
        user.create_user_setting(location: auth.info.location, tw_link: auth.info.urls.Twitter, info: auth.info.description)
        user
      else
        nil
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
