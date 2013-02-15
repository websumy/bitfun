class Users::FollowsController < ApplicationController
  before_filter :load_user, except: :index
  before_filter :only_xhr_request
  authorize_resource class: "UserRelationship"

  def index
    user = User.find_by_login!(params[:id])
    @users = if params[:type] == "following"
               user.followed_users.page params[:page]
             elsif params[:type] == "followers"
               user.followers.page params[:page]
             else
               []
             end
    respond_to do |format|
      format.html {render 'users/index'}
    end
  end

  def create
    current_user.follow!(@user)
    render json: { notice: t('follows.followed') }
  end

  def destroy
    current_user.unfollow!(@user)
    render json: { notice: t('follows.unfollowed') }
  end

  private
  def load_user
    @user = User.find_by_login!(params[:user_id])
  end
end