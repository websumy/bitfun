class Funs::RepostsController < ApplicationController

  # Shows 10 last users who reposted this fun
  def index
    users = Fun.find(params[:fun_id]).reposts.limit(10).reposters
    respond_to do |format|
      format.json { render json: users.as_json(:only => [:login, :avatar]) }
    end
  end

  # Create new repost by current_user for this fun
  def create
    authorize! :create, :repost
    fun = Fun.unscoped.find(params[:fun_id])
    new_fun = fun.repost_by current_user
    respond_to do |format|
        format.html { redirect_to new_fun, notice: t('reposts.created') }
        format.json { render json: { message: t('reposts.created'), type: "success" } }
    end
  end
end