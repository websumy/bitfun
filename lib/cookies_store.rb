class CookiesStore

  def initialize(cookies)
    @cookies = cookies
  end

  def set(data=[], keys=[])
    if keys.present?
      data.map do |k,v|
        if k.in? keys
          @cookies[k] = v unless @cookies[k] == v
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