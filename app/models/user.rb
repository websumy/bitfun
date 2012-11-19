class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :login, :password, :password_confirmation, :remember_me, :roles

  # Associations
  has_and_belongs_to_many :roles
  has_many :funs #, :dependent => :destroy

  # Callbacks
  before_create :set_default_role

  def role?(role)
    self.roles.exists?(:name => role.to_s)
  end

  def to_param
    login
  end

  private
  def set_default_role
    self.roles << Role.find_by_name(:user)
  end
end
