class MakingProjectMembershipUserIdAndProjectIdRequiredColumns < ActiveRecord::Migration
  def change
    ProjectMembership.where(user_id: nil).delete_all
    ProjectMembership.where(project_id: nil).delete_all
    change_column :project_memberships, :project_id, :integer, :null => false
    change_column :project_memberships, :user_id,    :integer, :null => false
  end
end
