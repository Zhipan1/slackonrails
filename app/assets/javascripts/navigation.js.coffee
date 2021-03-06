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

  $(".sidebar-channel a").click ->
    $(this).find(".sidebar-hash-tag").addClass("loading")
    $(this).find(".sidebar-hash-tag i").addClass("fa-spin")

  $(".form-modal-btn").click ->
    $modal = $($(this).attr("target"))
    $modal.show()
    setTimeout (-> $modal.addClass("active")), 50
    $modal.find(".big-close-btn").click ->
      $modal.removeClass("active")
      setTimeout (-> $modal.hide()), 200

  $(document).keydown (e) ->
    if e.keyCode == 27 and ($modal = $(".popup-modal-overlay.active")).length > 0
      $modal.removeClass("active")
      setTimeout (-> $modal.hide()), 200


  hideDropdown = ($target) ->
    $target.removeClass "active"
    setTimeout (-> $target.hide()), 300

  showDropdown = ($target) ->
    $target.show()
    setTimeout (->
      $target.addClass("active")
      $("body").on "click", showDropdownEvent
      ), 50

    showDropdownEvent = ->
      console.log 'a'
      hideDropdown($target)
      $("body").unbind("click", showDropdownEvent)








