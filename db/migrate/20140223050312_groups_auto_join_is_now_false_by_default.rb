class GroupsAutoJoinIsNowFalseByDefault < ActiveRecord::Migration
  def change
    change_column :groups, :auto_join, :boolean, default: false
  end
end
