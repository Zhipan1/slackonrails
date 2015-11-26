module ApplicationHelper
  def current_channel
    Channel.find_by_id(params[:id])
  end
end
