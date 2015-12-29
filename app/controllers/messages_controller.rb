class MessagesController < ApplicationController
  before_action :authenticate_user!
  include MessagesHelper

  def create
    thread, thread_membership = get_or_create_thread(thread_id, channel)
    @message = Message.create(message_params.merge(user: current_user))
    thread, slackbot_message = add_thread_to_mentioned_channels(thread, @message, channel)

    prev_message = channel.messages.last

    respond_to do |format|
      if thread.save and @message.save and (not slackbot_message or slackbot_message.save)
        format.html {}
        format.json {}
        # need to render new message + update dom
        rendered_message = render partial: 'messages/message', object: @message, locals: { prev_message: prev_message, channel: channel }
        update_dom = update_dom(@message, channel)
        PrivatePub.publish_to "/channels/#{channel.id}", message: rendered_message, user: @message.user.id, update_dom: update_dom, new_thread_head: (thread.messages.first.id if new_thread_head)
        if slackbot_message
          rendered_slack_message = render_to_string partial: 'messages/message', object: slackbot_message, locals: { prev_message: @message, channel: channel }
          # gotta wrap message in an array since render returns an array but render_to_string returns string
          PrivatePub.publish_to "/channels/#{channel.id}", message: [rendered_slack_message], user: slackbot_message.user.id
        end
        PrivatePub.publish_to "/channels/0", channel: channel.id
        channel.channel_memberships.where.not(user: current_user).update_all notification: true
      else
        format.html { render :nothing => true }
        format.json {}
      end
    end
  end

  def get_or_create_thread(thread_id, channel)

    if new_thread_head
      message = Message.find_by_id new_thread_head
      if message.message_thread == channel.main_thread
        thread = create_thread(message, channel)
      else
        thread = message.message_thread
      end
    else
      thread = MessageThread.find_by_id thread_id
    end

    membership = ThreadMembership.where(message_thread: thread, channel: channel).first

    [thread, membership]
  end

  def create_thread(head, channel)
    thread = MessageThread.create
    head.message_thread = thread
    head.save
    add_thread_to_channel(thread, channel, head)
    thread
  end

  def add_thread_to_mentioned_channels(thread, message, channel)
    channel_links = detect_channels(message.text)
    add_channels = []

    # add this thread to another channel
    if channel_links.empty?
      message.message_thread = thread
      return thread
    else
      # if message links to other channel and is in main thread, start a new thread
      if thread == channel.main_thread
        thread = create_thread(message, channel)
      else
        message.message_thread = thread
      end
      for channel in channel_links
        if not thread.channels.include? channel
          add_channels.append channel
        end
      end
    end

    slackbot_message = add_thread_to_channels_message(message.user, thread, add_channels) if not add_channels.empty?

    for channel in add_channels
      add_thread_to_channel(thread, channel, message)
    end

    [thread, slackbot_message]
  end

  def add_thread_to_channels_message(user, thread, channels)
    text = "#<add_channels_to_thread #{user.id}, #{thread.id}, #{channels.map{ |c| c.id}}>"
    Message.new user: User.first, message_thread: thread, text: text
  end

  def add_thread_to_channel(thread, channel, thread_head)
    ThreadMembership.where(message_thread: thread, channel: channel, head: thread_head).first_or_create
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
      params.require(:message).permit(:text)
    end

    def channel
      Channel.find params[:message][:channel_id]
    end

    def thread_id
      params[:message][:message_thread_id]
    end

    def new_thread_head
      params[:message][:new_thread_head_id]
    end

end
