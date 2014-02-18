class RemoveModeratorCanWriteFromOrganizationMemberships < ActiveRecord::Migration
  def change
    remove_column :organization_memberships, :moderator
    remove_column :organization_memberships, :can_write
  end
end
