class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def default_callback
    auth = request.env['omniauth.auth']

    # Find an identity here
    @identity = Identity.find_with_omniauth(auth)

    if @identity.nil?
      # If no identity was found, create a new one here
      @identity = Identity.create_with_omniauth(auth)
    end

    if signed_in?
      if @identity.user == current_user
        # User already linked that account
        redirect_to root_url, notice: "Already linked that account!"
      else
        # Associate the identity with the current_user
        @identity.user = current_user
        @identity.save
        redirect_to root_url, notice: "Successfully linked that account!"
      end
    else
      if @identity.user.present?
        # Signed in user
        flash[:notice] = "Signed in!"
        sign_in_and_redirect @identity.user, :event => :authentication
      else
        # No user associated with the identity so we need to create a new one
        user = User.create_with_omniauth(auth)
        if user.persisted?
          @identity.user = user
          @identity.save
          flash[:notice] = "Signed in!"
          sign_in_and_redirect @identity.user, :event => :authentication
        else
          redirect_to new_user_registration_url, notice: "Continue registration"
        end
      end
    end
  end

  Devise.omniauth_providers.each { |provider| alias_method provider, :default_callback }

  def passthru
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end
end
