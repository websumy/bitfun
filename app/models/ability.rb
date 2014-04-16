class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role? :admin
      can :manage, :all
    elsif user.role? :user
      can [:create, :feed, :autocomplete_tags], Fun
      can :destroy, Fun do |fun|
        fun.user_id == user.id && (
          fun.repost? || (fun.repost_counter == 0 && fun.in_sandbox?)
        )
      end
      can :create, :repost
      can [:create, :destroy], [UserRelationship, :like]
      can :update, Fun, user_id: user.id
      can :update, User, id: user.id
      can :create, Report
      can :read, :all
      can :create, Comment
      can :destroy, Comment, user_id: user.id, leaf?: true
      cannot [:destroy, :read], Report
      cannot :show, Notification
    else
      can :read, :all
    end
  end
end