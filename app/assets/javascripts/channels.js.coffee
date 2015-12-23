# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  channel = $("#channel-message-input").attr("channel-id")
  getThread = -> $("#channel-message-input").attr("message-thread-id")
  getNotifications(channel)
  $("#channel-body").scrollTop $("#messages").height()
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

  $("#channel-body").on 'click', '.message', (e) ->
    message_thread_id = $(this).attr("message-thread")
    $("#channel-message-input").attr("message-thread-id", message_thread_id).focus()

  PrivatePub.subscribe "/channels/#{channel}", (data, channel_url) ->
    if channel == channel_url.split("/channels/")[1]
      $("#messages").append data.message
      $("#channel-body").animate { scrollTop: $("#messages").height() }, "slow"

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

