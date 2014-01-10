class AddIdToGroupTables < ActiveRecord::Migration
  def change
    add_column :group_memberships, :id, :primary_key
    add_column :conversation_groups, :id, :primary_key
  end
end
