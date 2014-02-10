class AddingSummaryColumnToGroupMemberships < ActiveRecord::Migration
  def change
    add_column :group_memberships, :summary, :boolean, default: false, null: false
  end
end
