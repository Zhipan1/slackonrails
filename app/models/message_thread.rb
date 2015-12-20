class MessageThread < ActiveRecord::Base
  has_many :conversation_participants
  has_many :conversations
  has_many :messages
  has_many :channels, through: :conversations
  has_many :users, through: :conversation_participants
end
