class AddDailyLastMessageAtToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :daily_last_message_at, :datetime
  end
end
