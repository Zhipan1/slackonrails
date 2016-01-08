$ ->
  walkthrough() if $("#walkthrough-container").length > 0

walkthrough = ->
  $("#channel-body .messages").bind("new_message", tutorialStep1Show)
  $(".walkthrough-close, .skip-step-overlay").click ->
    step_num = parseInt $(this).attr("step")
    $(this).trigger("step_finished")
    walkthroughStepHide(step_num)
    walkthroughStepShow(step_num + 1)

  $(".walkthrough-close").on "step_finished", ->
    step_num = parseInt $(this).attr("step")
    if step_num == 1 # remove step 1 setup and set up step 2
      $("#channel-body .message").slice(0, 2).css("z-index": "")
      $user_message = $("#channel-body .message").slice(3, 4).addClass("hover")
      $("#channel-body .message").not($user_message).css("opacity": 0.5)
    else if step_num == 2 #remove step 2 setup
      $("#channel-body .message").slice(3, 4).removeClass("hover")
      $user_message = $("#channel-body .message").slice(3, 4)
      $("#channel-body .message").not($user_message).css("opacity": "")

walkthroughStepShow = (step) ->
  $(".step-#{step}").show()
  setTimeout (-> $(".step-#{step}").addClass("active")), 50

walkthroughStepHide = (step) ->
  $(".step-#{step}").removeClass("active")
  setTimeout (-> $(".step-#{step}").hide()), 300

tutorialStep1Show = ->
  $("#channel-body .message").slice(0, 2).css("z-index": 1)
  walkthroughStepShow(1)
  $("#channel-body .messages").unbind("new_message", tutorialStep1Show)

