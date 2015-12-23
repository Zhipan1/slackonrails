class MessageThread < ActiveRecord::Base
  has_many :thread_memberships
  has_many :channels, through: :thread_memberships
  has_many :messages
  has_many :users, -> { uniq }, through: :messages
end
