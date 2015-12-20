class Channel < ActiveRecord::Base
  has_many :conversations
  has_many :message_threads, through: :conversations
  has_many :messages, through: :message_threads
  has_many :channel_memberships
  has_many :users, through: :channel_memberships
  scope :direct_messages, -> { where(type: 'DirectMessage') }
  scope :public_channels, -> { where(type: 'PublicChannel') }

  def self.types
    %w(DirectMessage PublicChannel)
  end
end
