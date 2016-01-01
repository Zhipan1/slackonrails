# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  getInitialThreadCache = () ->
    cache = []
    for t in $(".message:not(.main-thread)").slice(-20).get().reverse()
      thread_num = parseInt $(t).attr("thread_id")
      if thread_num and cache.length < user_thread_cache_size and cache.indexOf(thread_num) == -1
        cache.push(thread_num)
    return cache

  pushToCache = (thread) ->
    if user_thread_cache.indexOf(thread) == -1
      user_thread_cache.pop()
      user_thread_cache.unshift(thread)

  updateThreadCache = ->
    thread_id = parseInt $("#channel-body .message").last().attr("thread_id")
    pushToCache(thread_id) if thread_id and thread_id != main_thread_id


  # channel data
  channel = $("#channel-message-input").attr("channel_id")
  getThread = -> $("#channel-message-input").attr("thread_id")
  getNewThreadHead = -> $("#thread-container").attr("new_thread_head_id")
  main_thread_id = $("#channel-message-input").attr("thread_id")
  current_user = parseInt($("#channel-message-input").attr("user_id"))
  user_thread_cache_size = 2
  window.t = user_thread_cache = getInitialThreadCache()
  user_thread_cache_index = [0]

  getNotifications(channel)
  $("#channel-body .messages-container").scrollTop $("#channel-body .messages").height()

  $("#collapse-all-threads").click -> ThreadShow($(this), "collapse")
  $("#collapse-non-user-threads").click -> ThreadShow($(this), "smart-collapse")
  $("#expand-all-threads").click -> ThreadShow($(this), "")

  ThreadShow = ($this, rule) ->
    $messages = $("#channel-body .messages")
    previous_thread_rule = $messages.attr("thread_collapse")
    $messages.removeClass(previous_thread_rule)
    $messages.addClass(rule)
    $messages.attr("thread_collapse", rule)
    $this.parent().find(".dropdown-item").removeClass("active")
    $this.addClass("active")

  $("#channel-message-input").focusin( ->
    $("#channel-message-box").addClass("focus")
    )
  .focusout( -> $("#channel-message-box").removeClass("focus") )

  $("#channel-message-input").focus().autosize(append: false).on 'autosize.resized', ->
    height = $("#channel-message-input").outerHeight()
    $("#channel-message-upload").css(height: height)

  $("#channel-message-input").keypress (e) ->
    if not e.shiftKey && e.which == 13
      if not $(this).val()
        return false
      text = $(this).val()
      postMessage(text, channel, getThread(), getNewThreadHead())
      $(this).val("")
      return false

  ## thread stuff ##

  $("#channel-message-input").keydown (e) ->
    return if $(this).val()
    # thread hotkeys
    if e.which == 38 #up
      clearThreadContainer()
      console.log user_thread_cache_index[0], user_thread_cache[user_thread_cache_index[0]]
      enableThreadView(user_thread_cache[user_thread_cache_index[0]])
      user_thread_cache_index[0] = (user_thread_cache_index[0] + 1) % user_thread_cache.length



  $(document).keydown (e) ->
    if e.keyCode == 27 and $("#thread-container").hasClass("active")
      disableThreadView()

  $("#thread-close").click disableThreadView

  $("#channel-body").on "mouseenter mouseleave", ".message", hoverThread

  $("#channel-body").on 'click', '.message .message-see-thread', (e) ->
    $message = $(this).parent().parent()
    thread_id = $message.attr("thread_id")
    enableThreadView(thread_id, $message)


  enableThreadView = (thread_id, $message=$()) ->
    message_id = $message.attr("message_id")
    $("#channel-message-input").attr("thread_id", thread_id).focus()
    $("#thread-container").attr("highlight_message", message_id)
    $message.addClass("highlight")

    if $message.hasClass("main-thread")
      $thread = $message.clone().addClass("first")
      $("#thread-container").attr("new_thread_head_id", $message.attr("message_id"))
      $("#thread-container").removeAttr("thread_id")
    else
      $thread = $(".message[thread_id='#{thread_id}']").clone().removeClass("color-thread before-head")
      $("#thread-container").attr("thread_id", thread_id)

    topic = $thread.first().find(".message-text").html()
    $("#thread-container .channel-topic").html(topic)
    $("#thread-container").show()
    $('#thread-container .messages').append($thread)

    setTimeout (->
      $("#thread-container").addClass("active")
      setTimeout (-> removeHighlight($("#thread-container").find(".highlight"))), 400
      ), 50

  disableThreadView = ($message=$()) ->
    message_id = $("#thread-container").attr("highlight_message")
    $message = $("#channel-body .message[message_id='#{message_id}']")
    $("#channel-message-input").attr("thread_id", main_thread_id)
    $("#thread-container").removeAttr("thread_id").removeAttr("new_thread_head_id").removeClass("active")

    user_thread_cache_index[0] = 0


    setTimeout (->
      $("#thread-container").hide()
      clearThreadContainer()
      ), 200

    setTimeout (-> removeHighlight($message)), 400

  clearThreadContainer = ->
    $('#thread-container .messages').empty()
    $("#thread-container .channel-topic").html("")


  PrivatePub.subscribe "/channels/#{channel}", (data, channel_url) ->
    if channel == channel_url.split("/channels/")[1]
      console.log data
      updateDom(data)
      updateThreadCache()



  appendNewMessage = ($message, user, new_thread_head) ->
    $("#channel-body .messages").append $message
    message_thread_id = $message.attr("thread_id")
    $("#channel-body .messages-container").animate { scrollTop: $("#channel-body .messages").height() }, "slow"

    if new_thread_head == parseInt $("#thread-container").attr("new_thread_head_id")
      $("#thread-container").attr("thread_id", message_thread_id).removeAttr("new_thread_head_id")
      $("#channel-message-input").attr("thread_id", message_thread_id)


    if $("#thread-container").hasClass('active') and $("#thread-container").attr("thread_id") == message_thread_id
      $plain_message = $message.clone().removeClass("color-thread")
      $("#thread-container .messages").append $plain_message
      $("#thread-container .messages-container").animate { scrollTop: $("#thread-container .messages").height() }, "slow"

  updateDom = (data) ->
    appendNewMessage($(data.message[0]), data.user, data.new_thread_head)
    if data.update_dom
      for message in data.update_dom
        if message.id
          new_message = $(message.render)
          old_message = $("#channel-body .message[message_id='#{message.id}']").addClass("highlight")
          old_message.replaceWith(new_message)

removeHighlight = ($element) ->
  $element.addClass("remove-highlight")
  setTimeout (->
    $element.removeClass("remove-highlight highlight")
  ), 600

hoverThread = (e) ->
  thread_id = $(this).attr("thread_id")
  $threads = $("#channel-body .message[thread_id='#{thread_id}'] .thread-bar")
  if $threads.hasClass("active")
    $threads.removeClass("active")
  else
    $threads.addClass("active")

postMessage = (text, channel, thread, new_thread_head) ->
  console.log text, channel, thread, new_thread_head
  $.ajax
    type: "POST"
    url: "/messages"
    data:
      message:
        text: text
        channel_id: channel
        message_thread_id: thread
        new_thread_head_id: new_thread_head
    error:(data) ->
      console.log data.responseText

searchMessage = (text) ->
  $.ajax
    type: "GET"
    url: "/messages/search"
    data:
      message:
        text: text
    success:(data) ->
      console.log data
    error:(data) ->
      console.log data.responseText




window.p = PrivatePub

