# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  channel = $("#channel-message-input").attr("channel-id")

  $("#channel-message-input").focus().autosize(append: false).keypress (e) ->
    if not e.shiftKey && e.which == 13
      text = $(this).val()
      postMessage(text, channel)
      $(this).val("")
      return false

  $("#message-search").keypress (e) ->
    if e.which == 13
      text = $(this).val()
      searchMessage text

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

  PrivatePub.subscribe "/channels/#{channel}", (data, channel) ->
    $("#messages").append data.message
    $("#channel-body").animate { scrollTop: $("#messages").height() }, "slow"
