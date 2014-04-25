class NotificationsController < ApplicationController
  authorize_resource

  def index
    @notifications = Fun.unscoped do
      Notification.includes({ fun: :content } , :user, :target, :subject)
      .where(receiver_id: current_user.id).order('created_at DESC').all
    end

    @list = Notification::List.new(@notifications)
  end
end
