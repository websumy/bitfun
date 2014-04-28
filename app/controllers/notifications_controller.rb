class NotificationsController < ApplicationController
  authorize_resource

  respond_to :html, :js

  def index
    @notifications = current_user.notifications_before(params[:date])
    @list = Notification::List.new(@notifications)

    respond_with(@notifications, @list)
  end
end
