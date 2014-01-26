class AddRelayedAtToSentEmails < ActiveRecord::Migration
  def change
    add_column :sent_emails, :relayed_at, :datetime, null: true
    add_index :sent_emails, [:relayed_at, :created_at]
  end
end
