class AddEmailAddressUsernameToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :email_address_username, :string
  end
end
