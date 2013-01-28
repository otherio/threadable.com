class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :conversation
      t.text :body
      t.boolean :reply
      t.string :subject
      t.string :children
      t.integer :parent_id
      t.string :message_id_header

      t.timestamps
    end
    add_index :messages, :conversation_id
  end
end
