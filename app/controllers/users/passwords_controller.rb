class Users::PasswordsController < Devise::PasswordsController
  before_filter :only_xhr_request, only: :new

  # GET /resource/password/new
  def new
    build_resource
    render layout: false
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      flash[:notice] = t('devise.passwords.send_instructions')
      render json: { success: true, redirect: root_path}
    else
      render json: { success: false, errors: t('user.filure.recover_pass') }
    end
  end

end
