class Users::FollowsController < ApplicationController
  before_filter :load_user, except: :index
  before_filter :only_xhr_request, except: :index
  authorize_resource class: 'UserRelationship'

  def index
    user = User.find_by_login!(params[:id])
    @users = if params[:type] == 'following'
               user.following_list.sorting(sort_column, sort_direction, sort_interval).page params[:page]
             elsif params[:type] == 'followers'
               user.followers_list.sorting(sort_column, sort_direction, sort_interval).page params[:page]
             else
               []
             end

    if request.xhr?
      render params[:page] ? 'users/index' : 'users/_table', layout: false
    else
      render 'users/index'
    end
  end

  def create
    current_user.follow!(@user)
    Stat.recount @user, :followers
    render json: { notice: t('follows.followed') }
  end

  def destroy
    current_user.unfollow!(@user)
    Stat.recount @user, :followers
    render json: { notice: t('follows.unfollowed') }
  end

  private
  def load_user
    @user = User.find_by_login!(params[:user_id])
  end
end