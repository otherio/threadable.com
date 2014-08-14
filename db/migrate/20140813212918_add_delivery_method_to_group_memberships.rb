class AddDeliveryMethodToGroupMemberships < ActiveRecord::Migration
  def up
    add_column :group_memberships, :delivery_method, :integer, null: false, default: 0
    execute("update group_memberships set delivery_method = 1 where summary = 't'")
    remove_column :group_memberships, :summary
    add_index :group_memberships, [:delivery_method, :user_id]
  end

  def down
    add_column :group_memberships, :summary, :boolean, null: false, default: false
    execute("update group_memberships set summary = 't' where delivery_method = 1")
    remove_column :group_memberships, :delivery_method
  end
end
