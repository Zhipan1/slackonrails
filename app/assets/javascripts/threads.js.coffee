$ ->


  $("#channel-message-input").keyup threadHotKeys

  $("#channel-message-input").keyup (e) ->
    if e.which == 27 or (e.which == 8 and not $(this).val())
      resetFocus()

  $("#channel-body .messages").on "new_message", ->
    resetFocus()



REPLY_BANNER_MARGIN = 11

@message_index = null
@thread_cache_up = []
@thread_cache_down = []

getMainThreadId = ->
  parseInt $("#channel-message-input").attr("main_thread_id")

getCache = (direction) ->
  if direction == "up"
    @thread_cache_up
  else
    @thread_cache_down

inThreadCache = (thread, direction) ->
  cache = getCache(direction)
  cache.indexOf(thread) != -1

removeFromCache = (thread, direction) ->
  cache = getCache(direction)
  if inThreadCache(thread, direction)
    index = cache.indexOf(thread)
    cache.splice(index, 1)
    console.log cache

addToCache = (thread, direction) ->
  cache = getCache(direction)
  if not inThreadCache(thread, direction)
    cache.push(thread)
  console.log getCache(direction)

resetCache = ->
  @thread_cache_up = []
  @thread_cache_down = []


resetFocus = ->
  removeFocus(get_message_at_index(current_message_index()))
  @message_index = null
  hideInputBoxBanner()
  resetCache()
  resetMetaData()

threadHotKeys = (e) ->
  return if $(this).val()
  # thread hotkeys
  if e.which == 38 # up
    focusMessage("up")

  else if e.which == 40 # down
    focusMessage("down")

focusMessage = (direction) ->
  $old_focus_message = get_message_at_index(current_message_index())
  if direction == "up"
    update_to_prev_message_index($old_focus_message)
    # new_direction = "up"
    # old_direction = "down"
  else
    update_to_next_message_index($old_focus_message)
    # new_direction = "down"
    # old_direction = "up"

  $new_focus_message = get_message_at_index(current_message_index())
  # new_thread_id = $new_focus_message.attr("thread_id")
  # old_thread_id = $old_focus_message.attr("thread_id") if $old_focus_message
  # addToCache(new_thread_id, new_direction) if not $new_focus_message.hasClass("main-thread")
  # removeFromCache(old_thread_id, old_direction)

  removeFocus($old_focus_message)
  addFocus($new_focus_message)
  scrollTo($new_focus_message)
  emphasize($new_focus_message)
  updateInputBox($new_focus_message)
  setInputMetaData($new_focus_message)

updateInputBox = ($message) ->
  $reply_to_banner = $("#reply-to-banner")
  $message_box = $("#channel-message-box")
  old_color_match = $message_box.attr("class").match(/thread-color-\d/)
  if old_color_match
    old_color = old_color_match[0]
    $message_box.removeClass(old_color)
  if $message.hasClass("main-thread")
    text = "@#{$message.find(".message-user").text()}"
  else
    text = "thread"
    thread_color_match = $message.attr("class").match(/thread-color-\d/)
    thread_color = thread_color_match[0] if thread_color_match
    $message_box.addClass(thread_color)


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

resetMetaData = ->
  $("#channel-message-input").removeAttr("new_thread_head_id")
  $("#channel-message-input").attr("thread_id", getMainThreadId())

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

scrollTo = ($message) ->
  $container = $("#channel-body .messages")
  offset = $message.offset().top - $container.offset().top + $container.scrollTop()
  $("#channel-body .messages-container").scrollTop offset

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
  $elements.css(opacity: 0.5)

clearEmphasis = ->
  $("#channel-body .message:visible").css(opacity: "")


update_to_prev_message_index = ($message) ->
  return if current_message_index() == 0

  decrement_message_index()

  return if not $message # $message is null when there is currently no messaging being focused

  if not $message.hasClass("main-thread") # go to prev message that's not in same thread
    thread_id = $message.attr("thread_id")
    $new_message = get_message_at_index(current_message_index())
    # decrement to the start of last message of new thread and to next non cached thread
    if ((new_thread_id = $new_message.attr("thread_id")) == thread_id)
      update_to_prev_message_index($new_message)

update_to_next_message_index = ($message) ->
  return if current_message_index() == null or current_message_index() == max_message_index()

  increment_message_index()

  return if not $message # $message is null when there is currently no messaging being focused

  if not $message.hasClass("main-thread") # go to prev message that's not in same thread
    thread_id = $message.attr("thread_id")
    $new_message = get_message_at_index(current_message_index())
    #increment to the start of last message of new thread and to next non cached thread
    if ((new_thread_id = $new_message.attr("thread_id")) == thread_id)
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





