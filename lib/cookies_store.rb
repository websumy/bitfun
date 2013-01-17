class CookiesStore
  attr_accessor :default_expires

  def initialize(cookies)
    @cookies = cookies
    @default_expires = 1.month.from_now
  end

  def set(data=[], keys=[])
    if keys.present?
      data.map do |k,v|
        if k.in? keys
          @cookies[k] = { value: v, expires: @default_expires } unless @cookies[k] == v
        end
      end
    end
  end

  def default_or_get(key, default)
    if default
      default
    elsif @cookies[key]
      data = @cookies[key].split("&")
      data.length > 1 ? data : data.first
    else
      nil
    end
  end

  def [](key)
    if @cookies[key]
      data = @cookies[key.to_s].split("&")
      data.length > 1 ? data : data.first
    else
      nil
    end
  end

end