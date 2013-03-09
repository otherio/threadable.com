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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130211014554) do

  create_table "conversations", :force => true do |t|
    t.string   "type"
    t.string   "subject"
    t.integer  "project_id"
    t.integer  "creator_id"
    t.string   "slug"
    t.datetime "due_at"
    t.datetime "done_at"
    t.integer  "messages_count", :default => 0
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "conversations", ["project_id"], :name => "index_conversations_on_project_id"

  create_table "events", :force => true do |t|
    t.string   "type"
    t.integer  "project_id",      :null => false
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at",      :null => false
  end

  add_index "events", ["conversation_id"], :name => "index_events_on_conversation_id"
  add_index "events", ["project_id"], :name => "index_events_on_project_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.text     "body"
    t.boolean  "reply"
    t.string   "from"
    t.string   "subject"
    t.string   "children"
    t.integer  "parent_id"
    t.string   "message_id_header"
    t.text     "references_header"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"

  create_table "project_memberships", :force => true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.boolean  "can_write",  :default => true
    t.boolean  "gets_email", :default => true
    t.boolean  "moderator",  :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "project_memberships", ["project_id", "user_id"], :name => "index_project_memberships_on_project_id_and_user_id", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "slug",        :null => false
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "projects", ["slug"], :name => "index_projects_on_slug", :unique => true

  create_table "task_doers", :force => true do |t|
    t.integer "user_id"
    t.integer "task_id"
  end

  add_index "task_doers", ["user_id", "task_id"], :name => "index_task_doers_on_user_id_and_task_id", :unique => true

  create_table "users", :force => true do |t|
    t.text     "name"
    t.string   "slug",                                   :null => false
    t.text     "email"
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "avatar_url"
    t.string   "provider"
    t.string   "uid"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true

end
