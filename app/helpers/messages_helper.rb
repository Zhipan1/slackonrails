module MessagesHelper
  def get_message_classes(message, prev_message, channel)
    classes = ""
    message_is_thread = message.message_thread.messages.count > 1
    prev_message_is_thread = (prev_message and prev_message.message_thread.messages.count > 1)
    prev_user = prev_message.user if prev_message

    diff_user = prev_user != message.user
    new_thread = ((prev_message_is_thread or message_is_thread) and prev_message and prev_message.message_thread != message.message_thread)
    new_time = (prev_message and (message.created_at - prev_message.created_at) > 10.minute)

    if message.message_thread.messages.count > 1
      classes += get_thread_classes(message, prev_message, message.next(channel))
    end
    if diff_user or new_thread or new_time
      classes += " first"
    end
    classes
  end

  def get_thread_classes(message, prev_message, next_message)
    classes = "color-thread thread-color-#{message.message_thread.id%8}"
    if not prev_message or message.message_thread != prev_message.message_thread
      classes += " thread-head"
    end
    if not next_message or message.message_thread != next_message.message_thread
      classes += " thread-tail"
    end
    classes
  end

  def update_dom(message, channel)
    dom = []
    thread = message.message_thread
    if thread.messages.count == 2
      head = thread.messages.first
      prev_message = head.prev(channel)
      next_message = head.next(channel)
      new_head = render_to_string partial: 'messages/message', object: head, locals: { prev_message: prev_message, channel: channel }
      new_next = render_to_string partial: 'messages/message', object: next_message, locals: { prev_message: head, channel: channel } if next_message
      dom += [{id: head.id, render: new_head}, {id: (next_message.id if next_message), render: new_next}]
    end
    if thread.messages.count > 1
      last_message = message.prev(channel)
      last_message_prev = last_message.prev(channel) if last_message
      new_last_message = render_to_string partial: 'messages/message', object: last_message, locals: { prev_message: last_message_prev, channel: channel } if last_message
      dom += [{id: (last_message.id if last_message), render: new_last_message}]
    end
    dom
  end

end
