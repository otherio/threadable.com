class AddActiveToOrganizationMembership < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :active, :boolean, default: true
    add_index :organization_memberships, [:active, :organization_id]
  end
end
