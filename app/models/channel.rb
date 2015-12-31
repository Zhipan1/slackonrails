class Channel < ActiveRecord::Base
  has_many :thread_memberships
  has_many :message_threads, through: :thread_memberships
  has_many :messages, through: :message_threads
  has_many :channel_memberships
  has_many :users, through: :channel_memberships
  belongs_to :main_thread, class_name: "MessageThread"
  scope :direct_messages, -> { where(type: 'DirectMessage') }
  scope :public_channels, -> { where(type: 'PublicChannel') }

  def messages_by_threads
    self.messages.order(:created_at)
  end

  def self.types
    %w(DirectMessage PublicChannel)
  end
end
