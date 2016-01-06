walkthrough_beginner = (options = {}) ->
  # walkthrough ===============================================================
  walkthrough = new WalkthroughModule("Thread Intro")

  # walkthrough content ====================================================

  # Thread intro

  walkthrough.addStep({
    title: "Student Answer",
    text: "Here is the first student's answer. Looks like she got it correct",
    attach_to: '#channel-body .message:last',
    orientation: "left",
    overlay: false
    })

  # Start walkthrough
  walkthrough.start()


window.walkthrough_beginner = walkthrough_beginner

