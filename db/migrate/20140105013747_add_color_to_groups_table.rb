class AddColorToGroupsTable < ActiveRecord::Migration
  def change
    add_column :groups, :color, :string, default: '#2ecc71'
  end
end
