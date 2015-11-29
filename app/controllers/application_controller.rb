class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include ActionView::Helpers::TagHelper

  def turbolinks_subscribe_to
    channel = "/channels/#{params[:channel_id]}"
    subscription = PrivatePub.subscription(:channel => channel)
    respond_to do |format|
      if subscription
        format.html { render text: "success" }
        format.json { render json: subscription }
      else
        format.html { render :nothing }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

end
