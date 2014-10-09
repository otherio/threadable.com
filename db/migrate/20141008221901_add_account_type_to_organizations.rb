class AddAccountTypeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :account_type, :integer, null: false, default: 0
  end
end
