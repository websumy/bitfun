module CookiesStore
  extend ActionController::Cookies

  included do
    helper_method :cookies_store
  end

  private
  def cookies_store
    'pyk'
  end

  def save(params=[])
    params.map do |k,v|
      if k.in? %w(type view interval)
        cookies[k] = v unless cookies[k] == v
      end
    end
  end

  def get(key, default)
    if cookies[key]
      data = cookies[key].split("&")
      data.length > 1 ? data : data.first
    else
      default
    end
  end

end