class UsersController < ApplicationController
  authorize_resource
  skip_authorize_resource only: :likes
  before_filter :load_user, except: :index
  before_filter :set_cookies, only: [:show, :likes]

  def index
    @users = User.all
  end

  def show
    @funs = @user.funs_with_reposts.includes(:content, :reposts).order('created_at DESC').page params[:page]
    respond_to do |format|
      format.html
      format.js { render 'funs/index' }
    end
  end

  def update
    if @user.update_attributes(params[:user], :as => current_user.role.name.to_sym)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find_by_login!(params[:id])
    if user == current_user
      redirect_to users_path, :notice => "Can't delete yourself."
    else
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    end
  end

  def likes
    @funs = @user.get_up_voted(Fun).includes(:content).order('votes.created_at DESC').page params[:page]
    respond_to do |format|
      format.html { render 'show' }
      format.js { render 'funs/index' }
    end
  end

  private
  def load_user
    @user = User.find_by_login!(params[:id])
  end

  def set_cookies
    cookies_store.set({view: params[:view]}) unless params[:view].nil?
  end
end