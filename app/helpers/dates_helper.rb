module DatesHelper
  def time_ago_format(date)
    content_tag :span, '', class: 'date_block date-time-format', data: {iso8601: date.to_time.iso8601}
  end
end