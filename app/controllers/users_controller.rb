class UsersController < ApplicationController
  authorize_resource
  skip_authorize_resource only: :likes
  before_filter :load_user, except: :index
  before_filter :set_cookies, only: [:show, :likes]
  helper_method :sort_column, :sort_direction, :sort_interval

  def index
    User.set_sort params if params
    @users = User.joins(:stat).includes(:stat).sorting.page params[:page]
  end

  def show
    @funs = @user.funs_with_reposts.includes(:content, :reposts, :user).order('created_at DESC').page params[:page]

    render 'funs/index.js.erb' if request.xhr?
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

  def sort_column
    User.sort_column
  end

  def sort_direction
    User.sort_direction
  end

  def sort_interval
    User.sort_interval
  end
end