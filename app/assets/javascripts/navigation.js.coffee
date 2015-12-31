$ ->
  current_channel = parseInt $("#channel-message-box textarea").attr('channel-id')
  getNotifications(0)
  PrivatePub.subscribe "/channels/0", (data, channel) ->
    notify = $("#channel-#{data.channel}")
    notify.addClass "unread-messages" if not notify.hasClass "active"
    if data.channel == current_channel
      $.ajax
        type: "POST"
        url: "/channels/#{data.channel}/clear"
        success:(data) ->
          # console.log data
        error:(data) ->
          console.log data.responseText

  $(".dropdown-menu-btn").click ->
    $target = $($(this).attr("target"))
    if $target.hasClass "active"
      hideDropdown($target)
    else
      showDropdown($target)

  $(".dropdown-item").click ->
    $target = $(this).parent()
    hideDropdown($target)

  hideDropdown = ($target) ->
    $target.removeClass "active"
    setTimeout (-> $target.hide()), 300

  showDropdown = ($target) ->
    $target.show()
    setTimeout (-> $target.addClass("active")), 50




