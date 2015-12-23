module ChannelsHelper
  def user_channel_membership(channel)
    ChannelMembership.where({user: current_user, channel: channel}).first
  end

  def clear_channel_notification(channel)
    channel_membership = user_channel_membership(channel)
    channel_membership.notification = false
    channel_membership.save
  end

  def channel_notification?(channel)
    user_channel_membership(channel).notification
  end

end
