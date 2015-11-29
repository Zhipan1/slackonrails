window.getNotifications = (channel)->
  $.ajax
    type: "GET"
    url: "/subscribe_to/#{channel}"
    success:(data) ->
      subscribe(data, channel)
    error:(data) ->
      console.log data.responseText
    dataType: "json"

window.subscribe = (params, channel) ->
  if not $(window).data("/channels/#{channel}")
    console.log "sub to channel #{channel}"
    PrivatePub.sign(params)
    $(window).data("/channels/#{channel}", true)
