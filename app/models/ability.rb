class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role? :admin
      can :manage, :all
    elsif user.role? :user
      can [:create, :feed, :autocomplete_tags], Fun
      can :destroy, Fun, user_id: user.id
      can :create, :repost
      can [:create, :destroy], [UserRelationship, :like]
      can :update, Fun, user_id: user.id
      can :update, User, id: user.id
      can :read, :all
    else
      can :read, :all
    end
  end
end