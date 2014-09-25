class AddDailyActiveUsersToOrgnizations < ActiveRecord::Migration
  def change
    add_column :organizations, :daily_active_users, :integer
  end
end
