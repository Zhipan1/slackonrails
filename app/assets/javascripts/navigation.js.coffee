$ ->
  PrivatePub.subscribe "/channels", (data, channel) ->
    notify = $("#channel-#{data.channel}")
    notify.addClass "unread-messages" if not notify.hasClass "active"


