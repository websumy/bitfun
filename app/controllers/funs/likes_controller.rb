class Funs::LikesController < ApplicationController
  before_filter :load_fun, expect: :index

  # Shows 10 last users who liked this fun
  def index
    users = Fun.find(params[:fun_id]).likes.limit(10).voters
    respond_to do |format|
      format.json { render json: users.as_json(:only => [:login, :avatar]) }
    end
  end

  # Like by current_user for this fun
  def create
    authorize! :create, :like
    @fun.like_by current_user
    respond_to do |format|
      format.html { redirect_to @fun, notice: t("likes.like") }
      format.json { render json: { type: :like } }
    end
  end

  # Unlike by current_user for this fun
  def destroy
    authorize! :destroy, :like
    @fun.unlike_by current_user
    respond_to do |format|
      format.html { redirect_to @fun, notice: t("likes.like") }
      format.json { render json: { type: :unlike } }
    end
  end

  private
  def load_fun
    @fun = Fun.unscoped.find(params[:fun_id])
  end
end