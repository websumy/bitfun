class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :user_activity
  helper_method :cookies_store, :sort_column, :sort_direction, :sort_interval

  unless Rails.env.development?
    rescue_from Exception, :with => :exception_catcher
  end

  private

  def only_xhr_request
    redirect_to root_path unless request.xhr?
  end

  def exception_catcher(exception)
    case exception
      when ActiveRecord::RecordNotFound, ActionController::UnknownController, ActionController::RoutingError
        render_404(exception)
      when CanCan::AccessDenied
        render_403(exception)
      else
        render_500(exception)
    end
  end

  def render_404(exception)
    exception_respond_with(404)
  end

  def render_500(exception)
    raise exception if show_detailed_exceptions?
    exception_respond_with(500)
  end

  def render_403(exception)
    exception_respond_with(403)
  end

  def exception_respond_with(status)
    respond_to do |format|
      format.html { render file: "public/#{status}", status: status, layout: false }
      format.xml { render xml: {error: status}, status: status, layout: false }
      format.json { render json: {error: status}, status: status, layout: false }
    end
  end

  def after_sign_in_path_for(resource)
    feed_path || root_path
  end

  def cookies_store
    @cookies_store ||= CookiesStore.new(cookies)
  end

  def user_activity
    current_user.try :touch, :last_response_at
  end

  def sort_column
    User.sort_column params[:sort]
  end

  def sort_direction
    User.sort_direction params[:direction]
  end

  def sort_interval
    User.sort_interval params[:interval]
  end

end
