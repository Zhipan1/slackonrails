$ ->


  $("#channel-message-input").keyup threadHotKeys

  $("#channel-message-input").keyup (e) ->
    if e.which == 27 or (e.which == 8 and not $(this).val())
      resetFocus()

  $("#channel-body .messages").on "new_message", ->
    resetFocus()


REPLY_BANNER_MARGIN = 11

@message_index = null
@thread_cache = []

resetFocus = ->
  removeFocus(get_message_at_index(current_message_index()))
  @message_index = null
  hideInputBoxBanner()

threadHotKeys = (e) ->
  return if $(this).val()
  # thread hotkeys
  if e.which == 38 # up
    focusMessage("up")

  else if e.which == 40 # down
    focusMessage("down")

focusMessage = (direction) ->
  $old_highlight_message = get_message_at_index(current_message_index())
  if direction == "up"
    update_to_prev_message_index($old_highlight_message)
  else
    update_to_next_message_index($old_highlight_message)
  $highlight_message = get_message_at_index(current_message_index())
  removeFocus($old_highlight_message)
  addFocus($highlight_message)
  emphasize($highlight_message)
  updateInputBox($highlight_message)
  setInputMetaData($highlight_message)

updateInputBox = ($message) ->
  $reply_to_banner = $("#reply-to-banner")
  if $message.hasClass("main-thread")
    text = "@#{$message.find(".message-user").text()}"
  else
    text = "thread"

  $reply_to_banner.text("reply to #{text}:")
  input_padding = $reply_to_banner.outerWidth() + REPLY_BANNER_MARGIN
  $("#channel-message-input").css("padding-left": input_padding)
  $reply_to_banner.show()

hideInputBoxBanner = ->
  $("#channel-message-input").css("padding-left": "")
  $("#reply-to-banner").hide()

setInputMetaData = ($message) ->
  thread_id = $message.attr("thread_id")
  $("#channel-message-input").attr("thread_id", thread_id)
  if $message.hasClass("main-thread")
    $("#channel-message-input").attr("new_thread_head_id", $message.attr("message_id"))
  else
    $("#channel-message-input").removeAttr("new_thread_head_id")

removeFocus = ($message) ->
  if not $message
    return false
  if $message.hasClass("main-thread")
    $message.removeClass("hover")
  else
    thread_id = $message.attr("thread_id")
    $("#channel-body .message[thread_id='#{thread_id}'").removeClass("hover")
  clearEmphasis()

addFocus = ($message) ->
  if not $message
    return false
  if $message.hasClass("main-thread")
    $message.addClass("hover")
  else
    thread_id = $message.attr("thread_id")
    $("#channel-body .message[thread_id='#{thread_id}'").addClass("hover")

emphasize = ($message) ->
  if not $message
    return false
  if $message.hasClass("main-thread")
    deemphasize($("#channel-body .message:visible").not($message))
  else
    thread_id = $message.attr("thread_id")
    $thread = $("#channel-body .message[thread_id='#{thread_id}'")
    deemphasize($("#channel-body .message:visible").not($thread))

deemphasize = ($elements) ->
  $elements.css(opacity: 0.2)

clearEmphasis = ->
  $("#channel-body .message:visible").css(opacity: "")


update_to_prev_message_index = ($message) ->
  return if current_message_index() == 0

  decrement_message_index()

  return if not $message # $message is null when there is currently no messaging being focused

  if not $message.hasClass("main-thread") # go to prev message that's not in same thread
    thread_id = $message.attr("thread_id")
    $new_message = get_message_at_index(current_message_index())
    if $new_message.attr("thread_id") == thread_id # decrement to the start of last message of new thread
      update_to_prev_message_index($new_message)

update_to_next_message_index = ($message) ->
  return if current_message_index() == null or current_message_index() == max_message_index()

  increment_message_index()

  return if not $message # $message is null when there is currently no messaging being focused

  if not $message.hasClass("main-thread") # go to prev message that's not in same thread
    thread_id = $message.attr("thread_id")
    $new_message = get_message_at_index(current_message_index())
    if $new_message.attr("thread_id") == thread_id #decrement to the start of last message of new thread
      update_to_next_message_index($new_message)


max_message_index = ->
  $("#channel-body .message:visible").length - 1

current_message_index = ->
  @message_index

increment_message_index = ->
  @message_index++

decrement_message_index = ->
  if @message_index
    @message_index--
  else
    @message_index = $("#channel-body .message:visible").length - 1

get_message_at_index = (index) ->
  $($("#channel-body .message:visible").get(index)) if index != null





