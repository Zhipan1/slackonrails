class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    @message = Message.new(message_params.merge user: current_user )
    channel = @message.channel
    prev_user = if channel.messages.last then channel.messages.last.user else nil end

    respond_to do |format|
      if @message.save
        format.html {}
        format.json {}
        rendered_message = render partial: 'messages/message', object: @message, locals: { prev_user: prev_user }
        PrivatePub.publish_to "/channels/#{channel.id}", message: rendered_message
        PrivatePub.publish_to "/channels", channel: channel.id
      else
        format.html { render :nothing => true }
        format.json {}
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:text, :channel_id)
    end
end
