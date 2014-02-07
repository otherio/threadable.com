class AddingGroupAndUngroupedMailDeliveryOptionsColumns < ActiveRecord::Migration
  def change
    remove_column :organization_memberships, :moderator, :boolean, default: false
    remove_column :organization_memberships, :can_write, :boolean, default: false
    add_column :organization_memberships, :ungrouped_delivery_method, :integer, default: 1, null: false
    add_index :organization_memberships, [:organization_id, :ungrouped_delivery_method], \
      name: "index_organization_memberships_on_org_id_and_ungrouped_convs" # auto gen name is too long
    add_column :group_memberships, :delivery_method, :integer, default: 1, null: false
    add_index :group_memberships, :delivery_method
  end
end
