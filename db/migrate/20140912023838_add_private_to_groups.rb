class AddPrivateToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :private, :boolean, null: false, default: false
  end
end
