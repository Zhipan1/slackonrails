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

end
