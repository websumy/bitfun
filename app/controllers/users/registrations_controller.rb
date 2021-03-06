class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :only_xhr_request, only: :new

  def new
    build_resource
    render layout: false
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_profile(params[resource_name])
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with(resource) do |format|
        format.html { render location: after_update_path_for(resource) }
        format.json { render json: { success: true, redirect: after_update_path_for(resource) } }
      end
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