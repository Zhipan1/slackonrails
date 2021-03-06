class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :wake_up_faye
  include ChannelsHelper

  def wake_up_faye
    PrivatePub.publish_to "wakeup", nil
  end

  # GET /channels
  # GET /channels.json
  def index
    @channels = PublicChannel.all
  end

  # POST
  def clear_notification
    set_channel
    respond_to do |format|
      if clear_channel_notification @channel
        format.html { render text: "success" }
        format.json { render text: "success" }
      else
        format.html { render :nothing }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
    clear_channel_notification(@channel)
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
  end

  # GET /channels/:id/join
  def user_join
    @channel = Channel.find(params[:channel_id])
    if not @channel.users.find_by_id(current_user)
      @memebership = ChannelMembership.new(user: current_user, channel: @channel)

      respond_to do |format|
        if @memebership.save
          format.html { redirect_to @channel, notice: "Successfully joined the #{@channel.name} channel" }
          format.json { render :show, status: :created, location: @channel }
        else
          format.html { render :new }
          format.json { render json: @channel.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to channels_path
    end
  end

  def join_channel(channel, user=current_user)
    ChannelMembership.where(user: user, channel: channel).first_or_create
  end

  # GET /channels/:id/join
  def user_leave
    @channel = Channel.find(params[:channel_id])
    if @channel.users.find_by_id(current_user)
      @memebership = ChannelMembership.where("user_id = ? AND channel_id = ?", current_user, @channel)

      respond_to do |format|
        if ChannelMembership.destroy @memebership
          format.html { redirect_to channels_path, notice: "You left the #{@channel.name} channel" }
          format.json { render :show, status: :created, location: @channel }
        else
          format.html { render :new }
          format.json { render json: @channel.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to channels_path
    end
  end

  # POST /channels
  # POST /channels.json
  def create
    @main_thread = MessageThread.new
    @channel = Channel.new(channel_params.merge main_thread: @main_thread)
    @memebership = ChannelMembership.new(user: current_user, channel: @channel)

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

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
        format.json { render :show, status: :ok, location: @channel }
      else
        format.html { render :edit }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url, notice: 'Channel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      @channel = Channel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def channel_params
      p = params.require(:channel).permit(:name, :topic)
      p[:name] = p[:name].downcase
      p
    end

end
