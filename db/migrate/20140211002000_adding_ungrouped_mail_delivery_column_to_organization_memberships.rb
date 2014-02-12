class AddingUngroupedMailDeliveryColumnToOrganizationMemberships < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :ungrouped_mail_delivery, :integer, default: 1
  end
end
