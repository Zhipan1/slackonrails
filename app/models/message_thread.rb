class MessageThread < ActiveRecord::Base
  has_many :thread_memberships
  has_many :channels, through: :thread_memberships
  has_many :messages
  has_many :users, -> { uniq }, through: :messages
  include MessagesHelper

  def post_message(user, message)
    msg = Message.create user: user, text: message, message_thread: self
    add_thread_to_mentioned_channels(self, msg)
  end

  def add_thread_to_mentioned_channels(thread, message)
    channel_links = detect_mentioned_channels(message.text)
    add_channels = []
    slackbot_message = nil

    # add this thread to another channel
    if channel_links.empty?
      return [message]
    else
      for channel in channel_links
        if not thread.channels.include? channel
          add_channels.append channel
        end
      end
    end

    if not add_channels.empty?
      slackbot_message = add_thread_to_channels_message(message.user, thread, add_channels)
      slackbot_message.save
    end

    for channel in add_channels
      add_thread_to_channel(self, channel, message)
    end

    [thread, slackbot_message]
  end

  def add_thread_to_channel(thread, channel, thread_head)
    ThreadMembership.where(message_thread: thread, channel: channel, head: thread_head).first_or_create
  end
end
