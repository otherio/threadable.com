class AddingRelationsAndStatusToIncomingEmails < ActiveRecord::Migration
  def change
    add_column :incoming_emails, :processed,         :boolean, default: false
    add_column :incoming_emails, :failed,            :boolean, default: false
    add_column :incoming_emails, :creator_id,        :integer
    add_column :incoming_emails, :project_id,        :integer
    add_column :incoming_emails, :conversation_id,   :integer
    add_column :incoming_emails, :parent_message_id, :integer
    add_column :incoming_emails, :message_id,        :integer

    create_table "attachments_incoming_emails", id: false, force: true do |t|
      t.integer "incoming_email_id"
      t.integer "attachment_id"
    end
  end
end
