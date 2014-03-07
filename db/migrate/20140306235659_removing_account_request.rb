class RemovingAccountRequest < ActiveRecord::Migration
  def change
    drop_table :account_requests
  end
end
