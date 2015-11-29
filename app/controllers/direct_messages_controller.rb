class DirectMessagesController < ChannelsController
  include DirectMessagesHelper

  def start_convo_between(user_1, user_2)
    @channel = DirectMessage.new
    @convo_to = Conversation.new(user: user_1, channel: @channel)
    @convo_from = Conversation.new(user: user_2, channel: @channel)

    if @channel.save and @convo_to.save and @convo_from.save
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
