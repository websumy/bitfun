class Funs::LikesController < ApplicationController
  before_filter :load_fun, expect: :index
  before_filter :only_xhr_request

  # Shows 5 last users who liked this fun
  def index
    users = @fun.likes.limit(5).voters
    users.map! do |user|
      user = user.info_to_json
      user[:user_path] = user_path user[:login]
      user
    end

    render json: users
  end

  # Like by current_user for this fun
  def create
    authorize! :create, :like
    @fun.like_by current_user
    Stat.recount @fun.user, :votes
    render json: { type: :like }
  end

  # Unlike by current_user for this fun
  def destroy
    authorize! :destroy, :like
    @fun.unlike_by current_user
    Stat.recount @fun.user, :votes
    render json: { type: :unlike }
  end

  private
  def load_fun
    @fun = Fun.unscoped.find(params[:fun_id])
  end
end