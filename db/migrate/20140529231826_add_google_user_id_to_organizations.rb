class AddGoogleUserIdToOrganizations < ActiveRecord::Migration
  def up
    add_column :organizations, :google_user_id, :integer

    Group.where(google_sync: true).each do |group|
      group.organization.update_attributes(google_user_id: group.google_sync_user_id)
    end

    remove_column :groups, :google_sync_user_id
  end

  def down
    add_column :groups, :google_sync_user_id, :integer

    Group.where(google_sync: true).each do |group|
      group.update_attributes(google_sync_user_id: group.organization.google_user_id)
    end

    remove_column :organizations, :google_user_id, :integer
  end
end
