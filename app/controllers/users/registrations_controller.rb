class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  def create_helper
    build_resource(sign_up_params)

    resource.save
    if resource.persisted?
      if resource.active_for_authentication?
        yield resource if block_given?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  def create
    create_helper do |user|
      join_default_channels(user)
      create_walkthrough(user)
      session[:new_user] = true
    end
  end

  def new
    super do
      PrivatePub.publish_to "wakeup", nil
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

  def create_walkthrough(user)
    examples_dir = "#{Rails.root}/examples"
    tutorial_channels_path = "#{examples_dir}/tutorial_channels.yml"
    tutorial_content_path = "#{examples_dir}/tutorial_content.yml"
    channels_seed = YAML::parse_file(tutorial_channels_path).to_ruby
    content_seed = YAML::parse_file(tutorial_content_path).to_ruby
    walkthrough_channels = create_walkthrough_channels(user, channels_seed)
    create_walkthrough_content(user, content_seed, walkthrough_channels)
  end

  def create_walkthrough_channels(user, channels_seed)
    channels = {}
    channels_seed.each do |c|
      channel = Channel.create c
      channel.add_user(user)
      channel.create_main_thread
      channels[channel.name] = channel
    end
    channels
  end

  def create_walkthrough_content(user, content_seed, walkthrough_channels)
    content_seed.each do |c|
      channel = walkthrough_channels[c["channel"]] || PublicChannel.where(name: c["channel"])
      threads = { "main" => channel.main_thread}
      c["content"].each do |data|
        thread = threads[data["thread"]]
        msg_user = User.where(name: data["name"]).first
        if not thread
          thread = threads[data["thread"]] = channel.new_thread
        end
        data["messages"].each do |msg|
          if data["origin"] and origin = walkthrough_channels[data["origin"]] || PublicChannel.where(name: data["origin"])
          else
            origin = channel
          end
          message, slackbot_message = thread.post_message(msg_user, msg, origin)
          if data["add_to_walkthrough_channels"]
            add_channels = data["add_to_walkthrough_channels"].map { |c| walkthrough_channels[c]}
            thread.add_thread_to_channels(add_channels, message)
          end
        end
      end
    end
  end

end
