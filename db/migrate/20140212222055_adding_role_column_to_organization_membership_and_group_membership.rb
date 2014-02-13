class AddingRoleColumnToOrganizationMembershipAndGroupMembership < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :role, :integer, default: 0
    add_column :group_memberships,        :role, :integer, default: 0
  end
end
