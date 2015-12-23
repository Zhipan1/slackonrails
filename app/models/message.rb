class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :message_thread
  has_many :channels, through: :message_thread
end
