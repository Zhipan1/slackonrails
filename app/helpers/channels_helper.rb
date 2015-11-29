module ChannelsHelper
  def user_convo(channel)
    Conversation.where({user: current_user, channel: channel}).first
  end

  def clear_channel_notification(channel)
    convo = user_convo(channel)
    convo.notification = false
    convo.save
  end

  def channel_notification?(channel)
    user_convo(channel).notification
  end
end
