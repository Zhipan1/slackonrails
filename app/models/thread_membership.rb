class ThreadMembership < ActiveRecord::Base
  belongs_to :message_thread
  belongs_to :channel
  belongs_to :head, class_name: 'Message'
end
