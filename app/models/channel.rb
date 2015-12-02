class Channel < ActiveRecord::Base
  validates :name, presence: true
  has_many :messages
  has_many :conversations
  has_many :users, through: :conversations
  scope :direct_messages, -> { where(type: 'DirectMessage') }
  scope :public_channels, -> { where(type: 'PublicChannel') }

  def self.types
    %w(DirectMessage PublicChannel)
  end
end
