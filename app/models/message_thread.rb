class MessageThread < ActiveRecord::Base
  has_many :thread_memberships
  has_many :channels, through: :thread_memberships
  has_many :messages
  has_many :users, -> { uniq }, through: :messages
  include MessagesHelper

  def post_message(user, message, origin)
    msg = Message.create user: user, text: message, message_thread: self, origin: origin
    messages = add_thread_to_mentioned_channels(msg)
    add_notifications(user)
    messages
  end

  def add_thread_to_mentioned_channels(message)
    channel_links = detect_mentioned_channels(message.text, message.user)
    add_channels = []
    slackbot_message = nil

    # add this thread to another channel
    if channel_links.empty?
      return [message]
    else
      for channel in channel_links
        if not self.channels.include? channel
          add_channels.append channel
        end
      end
    end

    add_thread_to_channels(add_channels, message)
  end

  def add_channel_to_thread(channel, thread_head=nil)
    ThreadMembership.where(message_thread: self, channel: channel, head: thread_head).first_or_create
    self
  end

  def add_thread_to_channels(channels, first_message)
    if not channels.empty?
      slackbot_message = add_thread_to_channels_message(first_message.user, self, channels)
      slackbot_message.save
    end

    for channel in channels
      self.add_channel_to_thread(channel, first_message)
    end

    [first_message, slackbot_message]
  end

  def add_notifications(user)
    self.channels.each do |c|
      c.channel_memberships.where.not(user: user).update_all notification: true
    end
  end

end
