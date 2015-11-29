json.array!(@channels) do |channel|
  json.extract! channel, :id, :user_id, :message_id, :topic
  json.url channel_url(channel, format: :json)
end
