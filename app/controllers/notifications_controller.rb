class NotificationsController < ApplicationController
  authorize_resource

  def index
    @notifications = Fun.unscoped do
      Notification.includes(:user, :target, :subject).where(receiver_id: current_user.id)
    end
  end
end
