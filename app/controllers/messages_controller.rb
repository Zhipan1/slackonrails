class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params.merge user: current_user )

    respond_to do |format|
      if @message.save
        format.html { render :nothing => true }
        format.json {}
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
