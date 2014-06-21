class RemoveUngroupedMailDeliveryFromOrganizationMembership < ActiveRecord::Migration
  def change
    remove_column :organization_memberships, :ungrouped_mail_delivery
  end
end
