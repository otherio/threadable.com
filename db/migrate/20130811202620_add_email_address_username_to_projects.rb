class AddEmailAddressUsernameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :email_address_username, :string
  end
end
