class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :password, :password_confirmation, :remember_me, :roles, :avatar, :avatar_cache, :remove_avatar

  mount_uploader :avatar, AvatarUploader
  validates_presence_of :avatar

  # Associations
  has_and_belongs_to_many :roles
  has_many :funs

  has_many :user_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :reverse_user_relationships, foreign_key: "followed_id", class_name: "UserRelationship", dependent: :destroy

  has_many :followed_users, through: :user_relationships, source: :followed
  has_many :followers, through: :reverse_user_relationships, source: :follower

  validates :login, presence: true, uniqueness: true

  # Callbacks
  before_create :set_default_role

  # Some helpers
  def role?(role)
    self.roles.exists?(:name => role.to_s)
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

  def feed
    Fun.from_users_followed_by(self)
  end

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

  private
  def set_default_role
    self.roles << Role.find_by_name(:user)
  end
end
