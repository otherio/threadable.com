class AddingNotNullContraintsToMessage < ActiveRecord::Migration
  def up
    Message.where(conversation_id: nil).delete_all
    change_column :messages, :conversation_id, :integer, :null => false
  end

  def down
    change_column :messages, :conversation_id, :integer, :null => true
  end
end
