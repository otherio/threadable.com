class AddAutoJoinToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :auto_join, :boolean, default: true, null: false
    add_index :groups, [:auto_join, :organization_id]
  end
end
