class PublicChannelsController < ChannelsController
  # POST /channels
  # POST /channels.json
  def create
    @channel = PublicChannel.new(channel_params)
    @convo = Conversation.new(user: current_user, channel: @channel)

    respond_to do |format|
      if @channel.save and @convo.save
        format.html { redirect_to @channel, notice: 'Channel was successfully created.' }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    @channels = PublicChannel.all
    @type = "Public Channel"
  end
end
