# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151227021244) do

  create_table "channel_memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "channel_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "notification", default: false
  end

  add_index "channel_memberships", ["channel_id"], name: "index_channel_memberships_on_channel_id"
  add_index "channel_memberships", ["user_id"], name: "index_channel_memberships_on_user_id"

  create_table "channels", force: :cascade do |t|
    t.string   "topic"
    t.string   "name"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "type",           default: "PublicChannel"
    t.integer  "main_thread_id"
  end

  add_index "channels", ["main_thread_id"], name: "index_channels_on_main_thread_id"

  create_table "message_threads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "text",              default: ""
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id"
    t.integer  "message_thread_id"
  end

  add_index "messages", ["message_thread_id"], name: "index_messages_on_message_thread_id"
  add_index "messages", ["user_id"], name: "index_messages_on_user_id"

  create_table "thread_memberships", force: :cascade do |t|
    t.integer  "message_thread_id"
    t.integer  "channel_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "head_id"
  end

  add_index "thread_memberships", ["channel_id"], name: "index_thread_memberships_on_channel_id"
  add_index "thread_memberships", ["head_id"], name: "index_thread_memberships_on_head_id"
  add_index "thread_memberships", ["message_thread_id"], name: "index_thread_memberships_on_message_thread_id"

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "image",                  default: "default-0.jpg"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.string   "email",                  default: "",              null: false
    t.string   "encrypted_password",     default: "",              null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,               null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
