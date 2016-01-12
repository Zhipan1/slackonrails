class MessagesController < ApplicationController
  before_action :authenticate_user!
  include MessagesHelper

  def create
    # cases
    # respond to a message, which creates a new thread
    # respond to a thread
    # - don't allow people to add another channel to the main thread, create a new one instead
    message_text = message_params[:text]
    message_channel = Channel.find message_params[:channel_id]
    message_user = current_user
    message_thread = MessageThread.find message_params[:message_thread_id]
    reply_to_message = Message.find_by_id message_params[:reply_to_message_id]

    if reply_to_message # replying to a individual message, create a new thread
      thread = MessageThread.create().add_channel_to_thread(message_channel, reply_to_message)
      reply_to_message.message_thread = thread
      reply_to_message.save

    elsif can_post_to_thread(message_text, message_channel, message_thread)
      thread = message_thread
    else
      thread = MessageThread.create().add_channel_to_thread(message_channel)
    end

    @message, slackbot_message = thread.post_message(message_user, message_text, message_channel)

    respond_to do |format|
      format.html { render :nothing => true }
      format.json {}
      if @message.save

        send_message_through_ajax(@message, message_channel, thread, reply_to_message)

        send_slackbot_message_through_ajax(slackbot_message, message_channel, thread) if slackbot_message

        send_push_notifications(message_channel)

      end
    end
  end

  # don't allow people to add another channel to the main thread, create a new one instead
  def can_post_to_thread(message_text, message_channel, message_thread)
    is_main = message_thread == message_channel.main_thread
    isnt_adding_another_channel = (detect_mentioned_channels(message_text, current_user) - [message_channel]).empty?
    (not is_main) or (is_main and isnt_adding_another_channel)
  end

  def render_message(message, channel)
    rendered_message = render_to_string partial: 'messages/message', object: message, locals: { prev_message: message.prev(channel), channel: channel }
    [rendered_message]
  end

  def send_message_through_ajax(message, channel, thread, new_thread=false)
    rendered_message = render_message(message, channel)
    update_dom = update_dom(message, channel) # update thread styles on affected messages
    PrivatePub.publish_to "/channels/#{channel.id}", message: rendered_message, user: message.user.id, update_dom: update_dom, new_thread_head: (thread.messages.first.id if new_thread), thread_id: thread.id
  end

  def send_slackbot_message_through_ajax(slackbot_message, channel, thread)
    rendered_message = render_message(slackbot_message, channel)
    # gotta wrap message in an array since render returns an array but render_to_string returns string
    PrivatePub.publish_to "/channels/#{channel.id}", message: rendered_message, user: slackbot_message.user.id
  end

  def send_push_notifications(channel)
    PrivatePub.publish_to "/channels/0", channel: channel.id
  end


  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:text, :channel_id, :message_thread_id, :reply_to_message_id)
    end


end
