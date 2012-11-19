class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role? :admin
      can :manage, :all
    elsif user.role? :user
      can :create, Fun
      can :update, Fun, user_id: user.id
      can :read, :all
    else
      can :read, :all
    end
  end
end