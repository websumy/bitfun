class UsersController < ApplicationController
  authorize_resource
  skip_authorize_resource only: [:likes, :rating_table_block]
  before_filter :load_user, except: [:index, :rating_table_block]
  before_filter :set_cookies, only: [:show, :likes]
  before_filter :only_xhr_request, only: :rating_table_block


  def index
    @users = User.joins(:stat).includes(:stat).sorting(sort_column, sort_direction, sort_interval).page params[:page]
    if request.xhr?
      render params[:page] ? 'index' : 'users/_rating', layout: false
    end
  end

  def show
    @funs = @user.funs_with_reposts.includes(:content, :reposts, :user, :owner).order('created_at DESC').page params[:page]
    @users = User.joins(:stat).includes(:stat).sorting('followers', 'desc', sort_interval).limit 5
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
    @funs = Fun.unscoped{ @user.get_up_voted(Fun) }.includes(:content).order('votes.created_at DESC').page params[:page]
    respond_to do |format|
      format.html { render 'show' }
      format.js { render 'funs/index' }
    end
  end

  def rating_table_block
    @users = User.joins(:stat).includes(:stat).sorting('followers', 'desc', sort_interval).limit 5
    render 'users/_rating_table_block', layout: false
  end

  private
  def load_user
    @user = User.find_by_login!(params[:id])
  end

  def set_cookies
    cookies_store.set({view: params[:view]}) unless params[:view].nil?
  end
end