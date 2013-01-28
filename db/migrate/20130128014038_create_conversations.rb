class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :subject
      t.references :project
      t.string :slug

      t.timestamps
    end
    add_index :conversations, :project_id
  end
end
