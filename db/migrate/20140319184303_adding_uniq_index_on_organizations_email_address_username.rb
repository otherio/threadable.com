class AddingUniqIndexOnOrganizationsEmailAddressUsername < ActiveRecord::Migration
  def change
    add_index :organizations, [:email_address_username], unique: true
  end
end
