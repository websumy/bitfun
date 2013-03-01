class Users::AvatarsController < ApplicationController
  before_filter :load_user
  before_filter :only_xhr_request

  def create
    avatar = params[:user][:avatar]
    avatar = avatar.first if avatar.class == Array

    @user.update_attribute(:avatar, avatar)
    respond_to do |format|
      format.html { render json: @user.to_jq_upload, content_type: 'text/html', layout: false }
      format.json { render json: @user.to_jq_upload }
    end
  end

  def destroy
    @user.remove_avatar!
    @user.update_attribute(:remove_avatar, true)
    render json: { success: true, url: @user.avatar_url }
  end

  private
  def load_user
    @user = User.find_by_login!(params[:user_id])
  end
end