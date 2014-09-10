class AddPermissionsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :group_membership_permission, :integer, null: false, default: 0
    add_column :organizations, :group_settings_permission, :integer, null: false, default: 0
  end
end
