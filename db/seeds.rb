# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

public_channels_list = [
  {name: "general", topic: "Generally a general channel for general topics of general discussion"},
  {name: "random", topic: "Ay lmao"},
  {name: "ay lmao", topic: "Ay lmao"}
]

users_list = [
  { name: "slackbot", email: "aylmao@aylmao.com", password: "password"},
  { name: "zhi", email: "z@z.z", password: "password"}
]

threads_list = [
  {
    messages: [
      { user: 2, text: "hi"},
      { user: 1, text: "hey! I'm slackbot"},
      { user: 2, text: "hi slackbot nice to meet you"},
    ],
    channels: [{ head: 2, channel: 1}, { head: 3, channel: 2}]
  },
  {
    messages: [
      { user: 2, text: "lalalalala"},
      { user: 1, text: "what can I do for u"},
      { user: 2, text: "order pizza"},
    ],
    channels: [{ head: 5, channel: 1}, { head: 4, channel: 3}]
  }
]

public_channels_list.each do |c|
  PublicChannel.create c
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
    ThreadMembership.create message_thread: thread, channel_id: c[:channel], message_id: c[:head]
  end
end




