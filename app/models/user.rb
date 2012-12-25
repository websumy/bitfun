class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Can vote for Funs
  acts_as_voter

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :name, :location, :info,
                  :site, :vk_link, :fb_link, :tw_link,
                  :password, :password_confirmation, :remember_me,
                  :avatar, :remote_avatar_url, :avatar_cache, :remove_avatar
  attr_accessible :role_id, as: :admin

  # Avatar uploader
  mount_uploader :avatar, AvatarUploader

  # Associations
  belongs_to :role
  has_many :funs

  # Followers and followed
  has_many :user_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_user_relationships, foreign_key: "followed_id", class_name: "UserRelationship", dependent: :destroy

  has_many :followed_users, through: :user_relationships, source: :followed
  has_many :followers, through: :reverse_user_relationships, source: :follower

  # Authorization services (FB, VK, TW)
  has_many :identities

  # Validation rules
  validates :login, :email, presence: true, uniqueness: true

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

  # Create user from oAuth data
  def self.create_with_omniauth auth
    case auth.provider
      when "facebook"
        create(email: auth.info.email, login: auth.info.nickname, remote_avatar_url: auth.info.image, password: Devise.friendly_token[0,10])
      when "vkontakte"
        create(email: auth.info.email, login: auth.info.nickname, remote_avatar_url: auth.info.image, password: Devise.friendly_token[0,10])
      when "twitter"
        create(email: auth.info.email, login: auth.info.nickname, remote_avatar_url: auth.info.image, password: Devise.friendly_token[0,10])
      else
        nil
    end
  end

  private
  def set_default_role
    self.role ||= Role.find_by_name(:user)
  end
end
