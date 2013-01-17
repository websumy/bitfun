class UsersController < ApplicationController
  authorize_resource
  skip_authorize_resource only: :likes
  before_filter :load_user, except: :index

  def index
    @users = User.all
  end

  def show
    @funs = @user.funs.includes(:content).order('created_at DESC').page params[:page]
    respond_to do |format|
      format.html
      format.js {render 'likes'}
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
      format.html {render 'show'}
      format.js
    end
  end

  private
  def load_user
    @user = User.find_by_login!(params[:id])
  end
end