class RenamingProjectToOrganization < ActiveRecord::Migration
  def change
    rename_column "conversations",       "project_id", "organization_id"
    rename_column "events",              "project_id", "organization_id"
    rename_column "incoming_emails",     "project_id", "organization_id"
    rename_column "project_memberships", "project_id", "organization_id"
    rename_table  "project_memberships", "organization_memberships"
    rename_table  "projects", "organizations"
  end
end
