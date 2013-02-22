class Users::AvatarsController < ApplicationController

  def create
    avatar = params[:user][:avatar]
    avatar = avatar.first if avatar.class == Array

    @user = User.find_by_login!(params[:user_id])
    if @user.update_attribute(:avatar, avatar)
      respond_to do |format|
        format.html {
          render json: @user.to_jq_upload,
                 content_type: 'text/html',
                 layout: false
        }
        format.json {
          render json: @user.to_jq_upload
        }
      end
    else
      render json: { error: 'custom_failure' }, status: 304
    end

  end

  def update

  end

  def destroy

  end
end