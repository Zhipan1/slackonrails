class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  require 'net/http'

  # DELETE /resource/sign_out
  def destroy
    super
  end

  def new
    super do
      PrivatePub.publish_to "wakeup", nil
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << :attribute
  end

end
