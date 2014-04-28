class Notification::Group
  attr_accessor :notifications, :time, :field, :value

  PERIOD  = 10
  FIELDS  = [:target, :user]
  WEIGHTS = {target: 2}

  def initialize(time, field, value, notifications = [])
    @time = time - PERIOD.minutes
    @field = field
    @value = value
    @notifications = notifications
  end

  def accept?(notification)
    notification.group_param(field) == value && time < notification.created_at
  end

  def first
    notifications.first
  end

  def weight
    notifications.length * (WEIGHTS[field] || 1)
  end

  def collect_msg_keys
    Hash.new(0).tap do |hash|
      notifications.each do |notification|
        hash[notification.msg_key(false)] += 1
      end
    end
  end

  def users_count
    notifications.collect(&:user_id).uniq.length
  end
end