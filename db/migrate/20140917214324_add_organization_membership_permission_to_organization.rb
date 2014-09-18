class AddOrganizationMembershipPermissionToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :organization_membership_permission, :integer, null: false, default: 0
  end
end
