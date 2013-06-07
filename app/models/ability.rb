class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.role? :admin
      can :manage, :all
    elsif user.role? :user
      can [:create, :feed, :autocomplete_tags], Fun
      can :destroy, Fun do |fun|
        fun.user_id == user.id && if fun.repost?
                                    true
                                  else
                                    fun.repost_counter == 0 && fun.parent.published_at
                                  end
      end
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