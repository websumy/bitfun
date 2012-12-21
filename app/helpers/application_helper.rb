module ApplicationHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def get_string_from_query query
    if query.is_a? Array
      query.join(",")
    elsif query.is_a? String
      query
    else
      query.to_s
    end
  end
end