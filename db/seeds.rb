# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

public_channels_list = [
  {name: "general", topic: "Generally a general channel for general topics of general discussion"},
  {name: "random", topic: "Ay-lmao"}
]

users_list = [
  { name: "slackbot", email: "aylmao@aylmao.com", password: "password", image: "slackbot.png"},
  { name: "zhi", email: "z@z.z", password: "password", image: "zhi.jpg"},
  { name: "drake", email: "drizzy@six.com", password: "password", image: "drake.jpg"},
  { name: "meek", email: "meek@sux.com", password: "password", image: "meek.jpg"},
  { name: "kevin", email: "kevin@intern.com", password: "password", image: "kevin.png" }
]

threads_list = [
]

public_channels_list.each do |c|
  channel = PublicChannel.create c.merge main_thread: MessageThread.create
  ThreadMembership.create message_thread: channel.main_thread, channel: channel
end

users_list.each do |u|
  User.create u
end

threads_list.each do |t|
  thread = MessageThread.create
  t[:messages].each do |m|
    Message.create user_id: m[:user], message_thread: thread, text: m[:text]
  end
  t[:channels].each do |c|
    ThreadMembership.create message_thread: thread, channel_id: c[:channel], head_id: c[:head]
  end
end




