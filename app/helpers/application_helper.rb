module ApplicationHelper
  def current_channel
    Channel.find_by_id(params[:id])
  end

  def turbolink_subscribe_to(channel)
    subscription = PrivatePub.subscription(:channel => channel)
    content_tag "script", type: "text/javascript", data: {turbolinks_eval: true} do
      raw("PrivatePub.sign(#{subscription.to_json});")
    end
  end

end
