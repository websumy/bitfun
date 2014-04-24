class Notification::Group
  attr_accessor :notifications, :time, :field, :value

  PERIOD = 30
  FIELDS = [:subject, :user, :target]

  def initialize(time, field, value, notifications = [])
    @time = time - PERIOD.minutes
    @field = field
    @value = value
    @notifications = notifications
  end

  def accept?(notification)
    notification.group_param(field) == value && time < notification.created_at
  end

  def user
    notifications.first.user
  end
end