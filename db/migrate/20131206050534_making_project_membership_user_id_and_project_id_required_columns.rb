class MakingOrganizationMembershipUserIdAndOrganizationIdRequiredColumns < ActiveRecord::Migration
  def change
    OrganizationMembership.where(user_id: nil).delete_all
    OrganizationMembership.where(project_id: nil).delete_all
    change_column :project_memberships, :project_id, :integer, :null => false
    change_column :project_memberships, :user_id,    :integer, :null => false
  end
end
