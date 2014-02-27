class AccountRequests < ActiveRecord::Migration
  def change
    create_table :account_requests do |t|
      t.string :organization_name, null: false
      t.string :email_address, null: false
      t.datetime :confirmed_at
      t.datetime :created_at, null: false
    end
  end
end
