class AddConversationsMutersTable < ActiveRecord::Migration
  def change

    create_table "conversations_muters", id: false, force: true do |t|
      t.integer "conversation_id"
      t.integer "user_id"
    end

    add_index "conversations_muters", ["conversation_id"]
    add_index "conversations_muters", ["conversation_id", "user_id"], unique: true

  end
end
