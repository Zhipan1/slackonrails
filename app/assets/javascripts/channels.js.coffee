# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#channel-message-input").focus().autosize(append: false).keypress (e) ->
    if not e.shiftKey && e.which == 13
      text = $(this).val()
      channel = $(this).attr("channel-id")
      postMessage(text, channel)
      location.reload();
      $(this).val("")
      return false

  postMessage = (text, channel) ->
    $.ajax
      type: "POST"
      url: "/messages"
      data:
        message:
          text: text
          channel_id: channel
      success:(data) ->
        console.log data.id
        return false
      error:(data) ->
        console.log data.responseText

