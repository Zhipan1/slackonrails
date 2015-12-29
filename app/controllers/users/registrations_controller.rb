class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  def create
    super do |user|
      join_default_channels(user)
    end

  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation).merge image: "default-#{User.count%3}.png"
  end

  def account_update_params
    params.require(:user).permit(:name, :image, :email, :password, :password_confirmation, :current_password)
  end

  def join_default_channels(user)
    channel_controller = ChannelsController.new()
    default_channels = [1, 2]
    default_channels.each do |c|
      channel_controller.join_channel Channel.find(c), user
    end
  end

end
