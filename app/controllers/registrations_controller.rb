class RegistrationsController < Devise::RegistrationsController

  def new
    build_resource
    if request.xhr?
      render layout: false
    else
      redirect_to root_path
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_profile(params[resource_name])
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource){ render :edit }
    end
  end

  def create
    build_resource
    if resource.save
      sign_up(resource_name, resource)
      render :json => { success: true, redirect: after_sign_up_path_for(resource) }
    else
      clean_up_passwords resource
      render json: { success: false, errors: t('registration.invalid') }
    end
  end

end