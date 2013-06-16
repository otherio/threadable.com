class CreateIncomingEmails < ActiveRecord::Migration
  def change
    create_table :incoming_emails do |t|
      t.text     :params,     :null => false
      t.datetime :created_at, :null => false
    end
  end
end
