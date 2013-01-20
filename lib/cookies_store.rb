class CookiesStore
  attr_accessor :default_expires

  def initialize(cookies)
    @cookies = cookies
    @default_expires = 1.month.from_now
  end

  def set(data=[])
    data.map do |key, value|
        @cookies[key] = { value: value, expires: @default_expires } if @cookies[key] != value
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