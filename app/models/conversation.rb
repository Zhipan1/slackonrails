class Conversation < ActiveRecord::Base
  belongs_to :channel
  belongs_to :message_thread
end
