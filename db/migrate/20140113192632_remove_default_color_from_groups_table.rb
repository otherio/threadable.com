class RemoveDefaultColorFromGroupsTable < ActiveRecord::Migration
  def change
    change_column :groups, :color, :string, null: false, default: ''
  end
end
