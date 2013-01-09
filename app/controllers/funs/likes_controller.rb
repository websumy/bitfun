class Funs::LikesController < ApplicationController

  # Shows 10 last users who liked this fun
  def index
    users = Fun.find(params[:fun_id]).likes.limit(10).voters
    respond_to do |format|
      format.json { render json: users.as_json(:only => [:login, :avatar]) }
    end
  end

  # Create new like by current_user for this fun
  def create
    @fun = Fun.find(params[:fun_id])
    type = if current_user.voted_up_on? @fun
             @fun.unliked_by voter: current_user
             "unlike"
           else
             @fun.liked_by current_user
             "like"
           end
    respond_to do |format|
      format.html { redirect_to @fun, notice: t('funs.liked') }
      format.json { render json: { type: type } }
    end
  end

end