class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
    user = User.find_by_login!(params[:id])
    funs = user.funs.includes(:content).page params[:page]
    @user = {info: user, funs: funs}
  end

  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find_by_login!(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find_by_login!(params[:id])
    if user == current_user
      redirect_to users_path, :notice => "Can't delete yourself."
    else
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    end
  end

  def following
    user = User.find_by_login!(params[:id])
    @users = user.followed_users.paginate(page: params[:page])
    render 'index'
  end

  def followers
    user = User.find_by_login(params[:id])
    @users = user.followers.paginate(page: params[:page])
    render 'index'
  end

  def follow
    @user = User.find(params[:user_relationship][:followed_id])
    if @user == current_user
      redirect_to users_path, :alert => "Can't follow yourself!"
    else
      current_user.follow!(@user)
      redirect_to @user
    end
  end

  def unfollow
    @user = User.find_by_login(params[:id])
    current_user.unfollow!(@user)
    redirect_to @user
  end
end