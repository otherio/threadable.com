class CreateIncomingIntegrationHooks < ActiveRecord::Migration
  def change
    create_table :incoming_integration_hooks do |t|
      t.text    :params,                   null: false
      t.string  :provider,                 null: false
      t.boolean :processed,                default: false
      t.integer :creator_id
      t.integer :organization_id
      t.integer :group_id
      t.integer :conversation_id
      t.integer :message_id
      t.string  :external_conversation_id
      t.string  :external_message_id
      t.timestamps
    end

    create_table :attachments_incoming_integration_hooks do |t|
      t.integer :incoming_integration_hook_id
      t.integer :attachment_id
    end
  end
end
