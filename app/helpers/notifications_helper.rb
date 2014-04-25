module NotificationsHelper

  def notification_group_users(group)
    [].tap do |parts|
      parts << link_to(group.first.user.login, group.first.user, class: 'info_title')
      rest = group.users_count - 1
      parts << t('notification.group.also_users', count: rest) if rest > 0
    end.join(' ').html_safe
  end

  def notification_group_actions(group)
    [].tap do |parts|
      group.collect_msg_keys.each do |action, count|
        parts << t("notification.group.#{group.field}.#{action}", count: count)
      end
    end.join(', ').html_safe
  end

  def notification_partial(notification)
    partial = (notification.subject_type == 'Comment') ? 'comment' : 'default'
    render "notifications/record/#{partial}", notification: notification
  end

end