class MessagesController < ApplicationController
  before_action :authenticate_user!
  def create
    @message = Message.new(message_params.merge user: current_user )
    channel = @message.channel
    @message.text = "ay lmao" if channel.name and channel.name.include? "ay lmao"
    prev_user = if channel.messages.last then channel.messages.last.user else nil end

    respond_to do |format|
      if @message.save
        format.html {}
        format.json {}
        rendered_message = render partial: 'messages/message', object: @message, locals: { prev_user: prev_user }
        PrivatePub.publish_to "/channels/#{channel.id}", message: rendered_message
        PrivatePub.publish_to "/channels/0", channel: channel.id
        channel.conversations.where.not(user: current_user).update_all notification: true
      else
        format.html { render :nothing => true }
        format.json {}
      end
    end
  end

  def search
    search = params[:message][:text]
    @messages = Message.where("text LIKE ?", "%#{search}%").all.sort

    respond_to do |format|
      if @messages.count > 0
        format.html { render partial: 'messages/search', object: @messages }
        format.json {  }
        # rendered_message = render partial: 'messages/message', object: @message, locals: { prev_user: prev_user }
      else
        format.html { render text: "Nothing found!" }
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
