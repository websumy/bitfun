class NotificationsController < ApplicationController
  authorize_resource

  def index
    @notifications = Fun.unscoped { Notification.includes(:user, :target, :subject).all }
  end
end
