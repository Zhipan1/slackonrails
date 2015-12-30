class PublicChannelsController < ChannelsController

  # GET /public_channels/new
  def new
    @channel = PublicChannel.new
  end


  # POST /public_channels
  # POST /public_channels.json
  def create
    @main_thread = MessageThread.new
    @channel = PublicChannel.new(channel_params.merge main_thread: @main_thread)
    @memebership = ChannelMembership.new(user: current_user, channel: @channel)
    ThreadMembership.create message_thread: @main_thread, channel: @channel

    respond_to do |format|
      if @main_thread.save and @channel.save and @memebership.save
        format.html { redirect_to @channel }
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

  private

  def channel_params
    p = params.require(:public_channel).permit(:name, :topic)
    p[:name] = p[:name].downcase
    p
  end
end
