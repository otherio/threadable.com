class ConversationCreatorCanNowBeBlank < ActiveRecord::Migration
  def change
    change_column "conversations", "creator_id", "integer", null: true
  end
end
