class DirectMessagesController < ChannelsController
  include DirectMessagesHelper

  # POST /direct_messages
  # POST /direct_messages.json
  def create
    @channel = DirectMessage.new(channel_params)
    @convo = Conversation.new(user: current_user, channel: @channel)

    respond_to do |format|
      if @channel.save and @convo.save
        format.html { redirect_to @channel }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

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

  private

  def channel_params
    p = params.require(:channel).permit(:name, :topic)
    p[:name] = p[:name].downcase
    p
  end

end
