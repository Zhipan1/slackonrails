# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  channel = $("#channel-message-input").attr("channel_id")
  getThread = -> $("#channel-message-input").attr("thread_id")
  getNewThreadHead = -> $("#thread-container").attr("new_thread_head_id")
  main_thread_id = $("#channel-message-input").attr("thread_id")
  current_user = parseInt($("#channel-message-input").attr("user_id"))
  getNotifications(channel)
  $("#channel-body .messages-container").scrollTop $("#channel-body .messages").height()

  $("#collapse-threads").click ->
    if $(this).attr("thread_collapse")
      $("#channel-body .messages").removeClass("collapse")
      $(this).attr("thread_collapse", "")
      setTimeout (-> $("#collapse-threads").text("Collapse threads")), 100
    else
      $("#channel-body .messages").addClass("collapse")
      $(this).attr("thread_collapse", true)
      setTimeout (-> $("#collapse-threads").text("Expand threads")), 100


  PrivatePub.subscribe "/channels/#{channel}", (data, channel_url) ->
    if channel == channel_url.split("/channels/")[1]
      console.log data
      updateDom(data)

  $("#channel-message-input").focusin( -> $("#channel-message-box").addClass("focus") ).focusout( -> $("#channel-message-box").removeClass("focus") )

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



  $("#message-search").keypress (e) ->
    if e.which == 13
      text = $(this).val()
      searchMessage text

  $("#channel-body").on "mouseenter mouseleave", ".message", hoverThread

  $("#channel-body").on 'click', '.message', (e) ->
    $message = $(this)
    thread_id = $message.attr("thread_id")
    enableThreadView(thread_id, $message)

    disableThreadKeyPress = (e) ->
      if e.keyCode == 27 and $("#thread-container").hasClass("active")
        disableThreadView($message)
        $(document).unbind('keydown', disableThreadKeyPress)
        $("#thread-container .channel-topic").html("")

    disableThreadClick = (e) ->
      disableThreadView($message)
      $("#thread-close").click(disableThreadClick)
      $("#thread-container .channel-topic").html("")

    $(document).bind('keydown', disableThreadKeyPress)
    $("#thread-close").click(disableThreadClick)


  enableThreadView = (thread_id, $message) ->
    $("#channel-message-input").attr("thread_id", thread_id).focus()
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

  disableThreadView = ($message) ->
    $("#channel-message-input").attr("thread_id", main_thread_id)
    $("#thread-container").removeAttr("thread_id").removeAttr("new_thread_head_id").removeClass("active")


    setTimeout (->
      $("#thread-container").hide()
      $('#thread-container .messages').empty()
      ), 200

    setTimeout (-> removeHighlight($message)), 400

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

