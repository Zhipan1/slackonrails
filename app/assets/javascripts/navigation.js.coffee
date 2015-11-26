$ ->
  PrivatePub.subscribe "/channels", (data, channel) ->
    console.log data.channel
