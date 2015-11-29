module DirectMessagesHelper
  def messaging?(direct_message)
    direct_message.users.where.not(id: current_user).first
  end

  def find_direct_message(user)
    (user.direct_messages & current_user.direct_messages).first
  end
end
