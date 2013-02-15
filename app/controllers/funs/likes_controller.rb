class Funs::LikesController < ApplicationController
  before_filter :load_fun, expect: :index
  before_filter :only_xhr_request

  # Shows 10 last users who liked this fun
  def index
    users = Fun.find(params[:fun_id]).likes.limit(10).voters
    render json: users.as_json(:only => [:login, :avatar])
  end

  # Like by current_user for this fun
  def create
    authorize! :create, :like
    @fun.like_by current_user
    render json: { type: :like }
  end

  # Unlike by current_user for this fun
  def destroy
    authorize! :destroy, :like
    @fun.unlike_by current_user
    render json: { type: :unlike }
  end

  private
  def load_fun
    @fun = Fun.unscoped.find(params[:fun_id])
  end
end