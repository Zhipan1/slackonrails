class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :message_thread
  has_many :channels, through: :message_thread

  def next(channel)
    channel.messages.where("messages.created_at > ?", self.created_at).first
  end

  def prev(channel)
    channel.messages.where("messages.created_at < ?", self.created_at).last
  end

  def before_head(channel)
    thread = self.message_thread
    membership = ThreadMembership.where(channel: channel, message_thread: thread).first
    head = membership.head if membership
    if head then self.created_at - head.created_at else 1 end
  end

end
