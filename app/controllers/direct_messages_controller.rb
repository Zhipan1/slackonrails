class DirectMessagesController < ChannelsController
  include DirectMessagesHelper

  # POST /direct_messages
  # POST /direct_messages.json
  def create
    @main_thread = MessageThread.new
    @channel = DirectMessage.new(channel_params.merge main_thread: @main_thread)
    @memebership = ChannelMembership.new(user: current_user, channel: @channel)
  end

  def start_convo_between(user_1, user_2)
    @main_thread = MessageThread.new
    @channel = DirectMessage.new(main_thread: @main_thread)
    @memebership_to = ChannelMembership.new(user: user_1, channel: @channel)
    @memebership_from = ChannelMembership.new(user: user_2, channel: @channel)
    ThreadMembership.create message_thread: @main_thread, channel: @channel

    if @main_thread.save and @channel.save and @memebership_to.save and @memebership_from.save
      return @channel
    else
      return false
    end
  end

  def start_convo_with(user)
    start_convo_between(current_user, user)
  end

  def direct_message
    user = User.find params[:user_id]
    @direct_message = find_direct_message user
    if @direct_message
      redirect_to @direct_message
    else
      @direct_message = start_convo_with user
      if @direct_message
        redirect_to @direct_message
      else
        render :error
      end
    end
  end

  def index
    @channels = DirectMessage.all
    @type = "Direct Message"
  end

end
