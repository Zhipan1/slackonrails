# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  channel = $("#channel-message-input").attr("channel_id")
  getThread = -> $("#channel-message-input").attr("thread_id")
  current_user = parseInt($("#channel-message-input").attr("user_id"))
  getNotifications(channel)
  $("#channel-body").scrollTop $("#channel-body .messages").height()

  PrivatePub.subscribe "/channels/#{channel}", (data, channel_url) ->
    if channel == channel_url.split("/channels/")[1]
      updateDom(data)


  $("#channel-message-input").focus().autosize(append: false).keypress (e) ->
    if not e.shiftKey && e.which == 13
      if not $(this).val()
        return false
      text = $(this).val()
      postMessage(text, channel, getThread())
      $(this).val("")
      return false

  $("#message-search").keypress (e) ->
    if e.which == 13
      text = $(this).val()
      searchMessage text

  $("#channel-body").on "mouseenter mouseleave", ".message", hoverThread

  $("#channel-body").on 'click', '.message', (e) ->
    thread_id = $(this).attr("thread_id")
    message_id = $(this).attr("message_id")
    enableThreadView(thread_id, message_id)

    disableThreadEvents = (e) ->
      if e.keyCode == 27 and $("#thread-container").hasClass("active")
        disableThreadView(message_id)
        $(document).unbind('keydown', disableThreadEvents)

    $(document).bind('keydown', disableThreadEvents)


  enableThreadView = (thread_id, message_id) ->
    $("#channel-message-input").attr("thread_id", thread_id).focus()
    $thread = $(".message[thread_id='#{thread_id}']").clone().removeClass("color-thread")
    $thread.first().addClass('first') if not $thread.first().hasClass('first')
    $("#thread-container").show().attr("thread_id", thread_id)
    $('#thread-container .messages').append($thread)
    $("#thread-container .message[message_id='#{message_id}']").addClass("highlight")
    setTimeout (-> $("#thread-container").addClass("active")), 50
    setTimeout (-> $("#channel-body .message[message_id='#{message_id}']").addClass("highlight")), 200

  disableThreadView = (message_id) ->
    $("#channel-message-input").attr("thread_id", "-1")
    $("#thread-container").removeClass("active")
    setTimeout (->
      $("#thread-container").hide()
      $('#thread-container .messages').empty()
      ), 200
    setTimeout (->
      $(".message[message_id='#{message_id}']").addClass("remove-highlight")
      setTimeout (->
        $(".message[message_id='#{message_id}']").removeClass("remove-highlight highlight")
        ), 800
      ), 400

  appendNewMessage = (message, user) ->
    $("#channel-body .messages").append message
    message_thread_id = $("#channel-body .messages .message").last().attr("thread_id")
    $("#channel-body").animate { scrollTop: $("#channel-body .messages").height() }, "slow"

    if $("#thread-container").hasClass('active') and $("#thread-container").attr("thread_id") == message_thread_id
      # remove thread color
      plain_message = $(message[0]).removeClass("color-thread")
      $("#thread-container .messages").append plain_message
      $("#thread-container").animate { scrollTop: $("#thread-container .messages").height() }, "slow"

  updateDom = (data) ->
    appendNewMessage(data.message, data.user)
    if data.update_dom
      for message in data.update_dom
        if message.id
          new_message = $(message.render)
          old_message = $("#channel-body .message[message_id='#{message.id}']").addClass("highlight")
          old_message.replaceWith(new_message)
          console.log new_message, old_message

hoverThread = (e) ->
  thread_id = $(this).attr("thread_id")
  $threads = $("#channel-body .message[thread_id='#{thread_id}'] .thread-bar")
  if $threads.hasClass("active")
    $threads.removeClass("active")
  else
    $threads.addClass("active")

postMessage = (text, channel, thread) ->
  $.ajax
    type: "POST"
    url: "/messages"
    data:
      message:
        text: text
        channel_id: channel
        message_thread_id: thread
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

