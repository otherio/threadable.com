class Init < ActiveRecord::Migration
  def change

    create_table "conversations", :force => true do |t|
      t.string   "subject"
      t.integer  "project_id"
      t.string   "slug"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "conversations", ["project_id"], :name => "index_conversations_on_project_id"

    create_table "messages", :force => true do |t|
      t.integer  "conversation_id"
      t.text     "body"
      t.boolean  "reply"
      t.string   "from"
      t.string   "subject"
      t.string   "children"
      t.integer  "parent_id"
      t.string   "message_id_header"
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

    create_table "task_followers", :force => true do |t|
      t.integer "user_id"
      t.integer "task_id"
    end

    add_index "task_followers", ["user_id", "task_id"], :name => "index_task_followers_on_user_id_and_task_id", :unique => true

    create_table "tasks", :force => true do |t|
      t.string   "name"
      t.string   "slug",       :null => false
      t.boolean  "done"
      t.datetime "due_at"
      t.integer  "project_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "tasks", ["slug"], :name => "index_tasks_on_slug", :unique => true

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
    end

    add_index "users", ["email"], :name => "index_users_on_email", :unique => true
    add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true


  end
end
