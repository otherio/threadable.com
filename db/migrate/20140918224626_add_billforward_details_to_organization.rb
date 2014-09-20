class AddBillforwardDetailsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :billforward_account_id, :string
    add_column :organizations, :billforward_subscription_id, :string

    add_index :organizations, [:billforward_subscription_id]
  end
end
