class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: exception.message
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    redirect_to root_path, alert: exception.message
  end

  def after_sign_in_path_for(resource)
    feed_path || root_path
  end

  def cookies_store
    @cookies_store ||= CookiesStore.new(cookies)
  end

  helper_method :cookies_store

end
