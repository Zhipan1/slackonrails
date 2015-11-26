class Channel < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :messages
  has_many :conversations
  has_many :users, through: :conversations
end
