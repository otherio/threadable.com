class MakingOrganizationMembershipUserIdAndOrganizationIdRequiredColumns < ActiveRecord::Migration
  def change
    OrganizationMembership.where(user_id: nil).delete_all
    OrganizationMembership.where(organization_id: nil).delete_all
    change_column :organization_memberships, :organization_id, :integer, :null => false
    change_column :organization_memberships, :user_id,    :integer, :null => false
  end
end
