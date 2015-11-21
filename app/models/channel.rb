class Channel < ActiveRecord::Base
  has_many :messages
  has_many :conversations
  has_many :users, through: :conversations
end
