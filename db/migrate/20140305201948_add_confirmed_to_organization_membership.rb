class AddConfirmedToOrganizationMembership < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :confirmed, :boolean, default: false
  end
end
