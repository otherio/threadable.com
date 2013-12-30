class AddingGroupsToConversations < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :email_address_tag
      t.integer :organization_id
      t.timestamps
    end
    add_index :groups, :organization_id
    add_index :groups, [:organization_id, :name], unique: true

    create_table :conversation_groups, :id => false do |t|
      t.integer :group_id
      t.integer :conversation_id
      t.boolean :active, default: true
    end
    add_index :conversation_groups, [:conversation_id, :group_id], unique: true
    add_index :conversation_groups, :group_id

    create_table :group_memberships, :id => false do |t|
      t.integer :group_id
      t.integer :user_id
    end
    add_index :group_memberships, [:user_id, :group_id], unique: true
    add_index :group_memberships, :group_id


    create_table :groups_incoming_emails, id: false do |t|
      t.integer :incoming_email_id
      t.integer :group_id
    end
    add_index :groups_incoming_emails, [:incoming_email_id, :group_id], unique: true

  end
end
