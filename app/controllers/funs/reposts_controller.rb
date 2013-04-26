class Funs::RepostsController < ApplicationController
  before_filter :load_fun, expect: :index
  before_filter :only_xhr_request

  # Shows 5 last users who reposted this fun
  def index
    users = @fun.get_reposts.limit(5).reposters
    users.map! do |user|
      user = user.info_to_json
      user[:user_path] = user_path user[:login]
      user
    end
    render json: users
  end

  # Create new repost by current_user for this fun
  def create
    authorize! :create, :repost
    @fun.repost_by current_user
    Stat.recount @fun.user, :reposts
    render json: { success: true }
  end

  private
  def load_fun
    @fun = Fun.unscoped.find(params[:fun_id])
  end
end