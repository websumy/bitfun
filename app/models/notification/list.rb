class Notification::List
  def initialize(notifications)
    @groups = []

    notifications.each do |notification|

      create = Notification::Group::FIELDS - append_to_groups(notification)
      create.each do |k|
        @groups << Notification::Group.new(notification.created_at, k,
                                           notification.group_param(k), [notification])
      end
    end

    clear_repeats
  end

  def append_to_groups(notification)
    [].tap do |exist|
      each do |group|
        if group.accept?(notification)
          group.notifications << notification
          exist << group.field
        end
      end
    end.uniq
  end

  def each
    @groups.each{ |g| yield g }
  end

  def clear_repeats
    used = {}
    weights = []
    @groups.each_with_index{ |g, i| weights << [i, g.notifications.length] }
    weights.sort{ |a, b| b[1] <=> a[1] }.each do |w|
      @groups[w[0]].notifications.delete_if do |notification|
        used[notification.id].tap { used[notification.id] = true }
      end
    end
    @groups.delete_if{ |group| group.notifications.empty? }
  end
end