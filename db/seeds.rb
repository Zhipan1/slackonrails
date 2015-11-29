# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

public_channels_list = [
  {name: "general", topic: "Generally a general channel for general topics of general discussion"},
  {name: "random", topic: "Ay lmao"}
]

users_list = [
  { name: "slackbot", email: "aylmao@aylmao.com", password: "password" }
]

public_channels_list.each do |c|
  PublicChannel.create c
end

users_list.each do |u|
  User.create u
end
