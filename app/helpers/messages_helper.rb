module MessagesHelper
  def get_message_classes(message, prev_message, channel)
    message_is_thread = message.message_thread.messages.count > 1
    prev_message_is_thread = (prev_message and prev_message.message_thread.messages.count > 1)
    prev_user = prev_message.user if prev_message

    diff_user = prev_user != message.user
    diff_thread = (prev_message and (prev_message.message_thread != message.message_thread))
    diff_time = (prev_message and (message.created_at - prev_message.created_at) > 10.minute)

    classes = get_thread_classes(message, prev_message, channel)

    classes += " first" if diff_user or diff_thread or diff_time

    classes
  end

  def get_thread_classes(message, prev_message, channel)
    classes = ""
    if channel.main_thread != message.message_thread
      next_message = message.next(channel)
      classes += "color-thread thread-color-#{message.message_thread.id%4}"
      if not prev_message or message.message_thread != prev_message.message_thread
        classes += " thread-head"
      end
      if not next_message or message.message_thread != next_message.message_thread
        classes += " thread-tail"
      end
    else
      classes += "main-thread"
    end
    classes
  end

  def update_dom(message, channel)
    dom = []
    thread = message.message_thread
    if thread != channel.main_thread
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

  def add_media(content)
    content.to_str.gsub(/#<(\w+)\s*(\w*)\s*,\s*(\w*)\s*,\s*([\[\w\],\s]*)>/) do |match|
      if $1 == "add_channels_to_thread"
        %(#{render_add_channels_message($2, $3, eval($4))})
      end
    end if content.present?
  end

  def render_add_channels_message(user_id, thread_id, channels_id)
    channels = channels_id.map{ |c| Channel.find_by_id c }
    render partial: 'messages/add_channels_message', object: nil, locals: { user: User.find_by_id(user_id), thread: MessageThread.find_by_id(thread_id), channels: channels }
  end

  def process_message(content)
    emojify(add_message_links(add_media(content)))
  end

  def detect_channels(content)
    links = []
    content.to_str.gsub(/(#(\w*))/) do |match|
      if channel = PublicChannel.find_by_name($2)
        links.append channel
      end
    end if content.present?
    links
  end

  def add_message_links(content)
    content.to_str.gsub(/(#(\w*))/) do |match|
      if channel = PublicChannel.find_by_name($2)
        %(#{link_to $1, channel})
      else
        match
      end
    end.html_safe if content.present?
  end

end
