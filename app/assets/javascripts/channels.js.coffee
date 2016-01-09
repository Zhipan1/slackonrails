# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->


  # channel data
  channel = $("#channel-message-input").attr("channel_id")
  getThread = -> $("#channel-message-input").attr("thread_id")
  getNewThreadHead = ->
    if id = $("#channel-message-input").attr("new_thread_head_id")
      parseInt id
    else
      null
  main_thread_id = parseInt $("#channel-message-input").attr("thread_id")
  current_user = parseInt($("#channel-message-input").attr("user_id"))

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

  $(document).keydown (e) ->
    if e.keyCode == 27 and $("#thread-container").hasClass("active")
      disableThreadView()

  $("#thread-close").click -> disableThreadView()

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
      $("#channel-message-input").attr("new_thread_head_id", $message.attr("message_id"))
      $("#thread-container").removeAttr("thread_id")
    else
      $thread = $(".message[thread_id='#{thread_id}']").clone().removeClass("color-thread before-head")
      $("#thread-container").attr("thread_id", thread_id)

    $first_message = $thread.first()
    topic = $first_message.find(".message-text").html()
    name = "<a>@#{$first_message.find(".message-user").text()}</a>: "
    $("#thread-container #header-thread-prompt").html([name, topic])
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
    $("#thread-container").removeAttr("thread_id").removeClass("active")
    $("#channel-message-input").removeAttr("new_thread_head_id")

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
      $("#channel-body .messages").trigger("new_message")



  appendNewMessage = ($message, user, new_thread_head) ->
    $("#channel-body .messages").append $message
    message_thread_id = $message.attr("thread_id")
    $("#channel-body .messages-container").animate { scrollTop: $("#channel-body .messages").height() }, "slow"

    if new_thread_head == getNewThreadHead()
      $("#thread-container").attr("thread_id", message_thread_id)
      $("#channel-message-input").attr("thread_id", message_thread_id).removeAttr("new_thread_head_id")


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
        new_thread_head_id: new_thread_head if new_thread_head != null
    error:(data) ->
      console.log data.responseText

