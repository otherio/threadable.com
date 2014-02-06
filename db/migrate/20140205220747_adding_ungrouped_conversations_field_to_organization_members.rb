class AddingUngroupedConversationsFieldToOrganizationMembers < ActiveRecord::Migration
  def change
    remove_column(:organization_memberships, :moderator, :boolean, default: false)
    remove_column(:organization_memberships, :can_write, :boolean, default: false)
    add_column(:organization_memberships, :ungrouped_conversations, :integer, default: 1, null: false)
    add_index :organization_memberships, [:organization_id, :ungrouped_conversations], \
      name: "index_organization_memberships_on_org_id_and_ungrouped_convs" # auto gen name is too long
  end
end
