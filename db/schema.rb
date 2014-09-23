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

ActiveRecord::Schema.define(version: 20140918224626) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "api_access_tokens", force: true do |t|
    t.integer  "user_id",                   null: false
    t.string   "token",                     null: false
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
  end

  create_table "attachments", force: true do |t|
    t.string   "url"
    t.string   "filename"
    t.string   "mimetype"
    t.integer  "size"
    t.boolean  "writeable"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "content_id"
    t.boolean  "inline",     default: false, null: false
  end

  add_index "attachments", ["inline"], name: "index_attachments_on_inline", using: :btree

  create_table "attachments_incoming_emails", id: false, force: true do |t|
    t.integer "incoming_email_id"
    t.integer "attachment_id"
  end

  create_table "attachments_messages", id: false, force: true do |t|
    t.integer "message_id"
    t.integer "attachment_id"
  end

  add_index "attachments_messages", ["message_id"], name: "index_attachments_messages_on_message_id", using: :btree

  create_table "conversation_groups", force: true do |t|
    t.integer "group_id"
    t.integer "conversation_id"
    t.boolean "active",          default: true
  end

  add_index "conversation_groups", ["conversation_id", "group_id"], name: "index_conversation_groups_on_conversation_id_and_group_id", unique: true, using: :btree
  add_index "conversation_groups", ["group_id"], name: "index_conversation_groups_on_group_id", using: :btree

  create_table "conversations", force: true do |t|
    t.string   "type"
    t.text     "subject",                                   null: false
    t.integer  "organization_id",                           null: false
    t.integer  "creator_id"
    t.integer  "position"
    t.string   "slug",                                      null: false
    t.datetime "done_at"
    t.integer  "messages_count",          default: 0
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "group_ids_cache"
    t.text     "message_summary_cache"
    t.text     "participant_names_cache"
    t.text     "muter_ids_cache"
    t.datetime "last_message_at",         default: "now()"
    t.integer  "groups_count",            default: 0
    t.datetime "trashed_at"
    t.text     "follower_ids_cache"
  end

  add_index "conversations", ["organization_id", "slug"], name: "index_conversations_on_organization_id_and_slug", unique: true, using: :btree
  add_index "conversations", ["organization_id"], name: "index_conversations_on_organization_id", using: :btree
  add_index "conversations", ["slug"], name: "index_conversations_on_slug", using: :btree
  add_index "conversations", ["trashed_at"], name: "index_conversations_on_trashed_at", using: :btree

  create_table "conversations_followers", id: false, force: true do |t|
    t.integer "conversation_id"
    t.integer "user_id"
  end

  add_index "conversations_followers", ["conversation_id", "user_id"], name: "index_conversations_followers_on_conversation_id_and_user_id", unique: true, using: :btree
  add_index "conversations_followers", ["conversation_id"], name: "index_conversations_followers_on_conversation_id", using: :btree

  create_table "conversations_muters", id: false, force: true do |t|
    t.integer "conversation_id"
    t.integer "user_id"
  end

  add_index "conversations_muters", ["conversation_id", "user_id"], name: "index_conversations_muters_on_conversation_id_and_user_id", unique: true, using: :btree
  add_index "conversations_muters", ["conversation_id"], name: "index_conversations_muters_on_conversation_id", using: :btree

  create_table "email_addresses", force: true do |t|
    t.integer  "user_id"
    t.text     "address",                      null: false
    t.boolean  "primary",      default: false
    t.datetime "confirmed_at"
  end

  add_index "email_addresses", ["address"], name: "index_email_addresses_on_address", unique: true, using: :btree
  add_index "email_addresses", ["primary"], name: "index_email_addresses_on_primary", using: :btree
  add_index "email_addresses", ["user_id"], name: "index_email_addresses_on_user_id", using: :btree

  create_table "email_domains", force: true do |t|
    t.integer "organization_id"
    t.string  "domain",                          null: false
    t.boolean "outgoing",        default: false, null: false
  end

  add_index "email_domains", ["domain"], name: "index_email_domains_on_domain", using: :btree

  create_table "events", force: true do |t|
    t.string   "event_type"
    t.integer  "organization_id", null: false
    t.integer  "conversation_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at",      null: false
  end

  add_index "events", ["conversation_id"], name: "index_events_on_conversation_id", using: :btree
  add_index "events", ["organization_id"], name: "index_events_on_organization_id", using: :btree
  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

  create_table "external_authorizations", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "token"
    t.string   "secret"
    t.string   "name"
    t.string   "email_address"
    t.string   "nickname"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "refresh_token"
    t.string   "domain"
  end

  add_index "external_authorizations", ["user_id", "provider"], name: "index_external_authorizations_on_user_id_and_provider", unique: true, using: :btree

  create_table "group_memberships", force: true do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.integer "role",            default: 0
    t.integer "delivery_method", default: 0, null: false
  end

  add_index "group_memberships", ["delivery_method", "user_id"], name: "index_group_memberships_on_delivery_method_and_user_id", using: :btree
  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true, using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.string   "email_address_tag"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color",               default: "",    null: false
    t.string   "subject_tag"
    t.boolean  "auto_join",           default: false, null: false
    t.boolean  "hold_messages",       default: true
    t.string   "alias_email_address", default: "",    null: false
    t.string   "webhook_url",         default: "",    null: false
    t.boolean  "google_sync",         default: false, null: false
    t.string   "description"
    t.boolean  "primary",             default: false, null: false
  end

  add_index "groups", ["auto_join", "organization_id"], name: "index_groups_on_auto_join_and_organization_id", using: :btree
  add_index "groups", ["email_address_tag"], name: "index_groups_on_email_address_tag", using: :btree
  add_index "groups", ["organization_id", "name"], name: "index_groups_on_organization_id_and_name", unique: true, using: :btree
  add_index "groups", ["organization_id"], name: "index_groups_on_organization_id", using: :btree

  create_table "groups_incoming_emails", id: false, force: true do |t|
    t.integer "incoming_email_id"
    t.integer "group_id"
  end

  add_index "groups_incoming_emails", ["incoming_email_id", "group_id"], name: "index_groups_incoming_emails_on_incoming_email_id_and_group_id", unique: true, using: :btree

  create_table "incoming_emails", force: true do |t|
    t.text     "params",                            null: false
    t.datetime "created_at",                        null: false
    t.boolean  "processed",         default: false
    t.boolean  "bounced",           default: false
    t.integer  "creator_id"
    t.integer  "organization_id"
    t.integer  "conversation_id"
    t.integer  "parent_message_id"
    t.integer  "message_id"
    t.boolean  "held",              default: false
  end

  add_index "incoming_emails", ["held"], name: "index_incoming_emails_on_held", using: :btree

  create_table "messages", force: true do |t|
    t.integer  "conversation_id",                     null: false
    t.integer  "user_id"
    t.text     "body_plain"
    t.boolean  "reply"
    t.string   "from"
    t.text     "subject"
    t.string   "children"
    t.integer  "parent_id"
    t.string   "message_id_header"
    t.text     "references_header"
    t.boolean  "shareworthy",         default: false
    t.boolean  "knowledge",           default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "stripped_plain",      default: ""
    t.text     "body_html",           default: ""
    t.text     "stripped_html",       default: ""
    t.string   "date_header"
    t.text     "to_header"
    t.text     "cc_header"
    t.text     "thread_index_header"
    t.text     "thread_topic_header"
  end

  add_index "messages", ["conversation_id", "user_id"], name: "index_messages_on_conversation_id_and_user_id", using: :btree
  add_index "messages", ["created_at"], name: "index_messages_on_created_at", using: :btree
  add_index "messages", ["message_id_header"], name: "index_messages_on_message_id_header", using: :btree
  add_index "messages", ["thread_index_header"], name: "index_messages_on_thread_index_header", using: :btree

  create_table "organization_memberships", force: true do |t|
    t.integer  "organization_id",                 null: false
    t.integer  "user_id",                         null: false
    t.boolean  "gets_email",      default: true
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "role",            default: 0
    t.boolean  "active",          default: true
    t.boolean  "confirmed",       default: false
  end

  add_index "organization_memberships", ["active", "organization_id"], name: "index_organization_memberships_on_active_and_organization_id", using: :btree
  add_index "organization_memberships", ["organization_id", "user_id"], name: "index_organization_memberships_on_organization_id_and_user_id", unique: true, using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "slug",                                               null: false
    t.text     "description"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "subject_tag"
    t.string   "email_address_username"
    t.boolean  "trusted",                            default: false
    t.boolean  "hold_all_messages",                  default: false, null: false
    t.integer  "google_user_id"
    t.integer  "plan",                               default: 0,     null: false
    t.boolean  "public_signup",                      default: false, null: false
    t.integer  "group_membership_permission",        default: 0,     null: false
    t.integer  "group_settings_permission",          default: 0,     null: false
    t.integer  "organization_membership_permission", default: 0,     null: false
    t.string   "billforward_account_id"
    t.string   "billforward_subscription_id"
  end

  add_index "organizations", ["billforward_subscription_id"], name: "index_organizations_on_billforward_subscription_id", using: :btree
  add_index "organizations", ["email_address_username"], name: "index_organizations_on_email_address_username", unique: true, using: :btree
  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "sent_emails", force: true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.integer  "email_address_id"
    t.datetime "created_at"
    t.datetime "relayed_at"
  end

  add_index "sent_emails", ["message_id", "user_id"], name: "index_sent_emails_on_message_id_and_user_id", unique: true, using: :btree
  add_index "sent_emails", ["relayed_at", "created_at"], name: "index_sent_emails_on_relayed_at_and_created_at", using: :btree

  create_table "task_doers", force: true do |t|
    t.integer "user_id"
    t.integer "task_id"
  end

  add_index "task_doers", ["user_id", "task_id"], name: "index_task_doers_on_user_id_and_task_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.text     "name"
    t.string   "slug",                                    null: false
    t.string   "encrypted_password",      default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "avatar_url"
    t.string   "provider"
    t.string   "uid"
    t.boolean  "admin"
    t.integer  "current_organization_id"
    t.boolean  "munge_reply_to",          default: false
    t.boolean  "dismissed_welcome_modal", default: false, null: false
    t.boolean  "show_mail_buttons",       default: true
    t.boolean  "secure_mail_buttons",     default: false
  end

  add_index "users", ["created_at"], name: "index_users_on_created_at", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true, using: :btree

end
