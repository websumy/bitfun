class SessionsController < Devise::SessionsController

  def new
    self.resource = build_resource(nil, :unsafe => true)
    clean_up_passwords(resource)
    if request.xhr?
     render layout: false
    else
     redirect_to root_path
    end
  end

  def create
    resource = warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    sign_in(resource_name, resource)
    render :json => { success: true, redirect: after_sign_in_path_for(resource) }
  end

  def failure
    render json: { success: false, errors: t('devise.failure.invalid') }
  end

  def destroy
    warden.user.update_attribute :last_response_at, nil
    super
  end
end