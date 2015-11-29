class Conversation < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel
  belongs_to :public_channel
  belongs_to :direct_message
end
