class AddGoogleSyncToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :google_sync, :boolean, null: false, default: false
    add_column :groups, :google_sync_user_id, :integer
  end
end
