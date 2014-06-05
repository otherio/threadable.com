class AddIndicesToIncomingEmails < ActiveRecord::Migration
  def change
    add_index :incoming_emails, [:held]
  end
end
