class RemoveDotFromEmailAddressUsername < ActiveRecord::Migration
  def up
    Organization.where("email_address_username LIKE '%.%'").map do |organization|
      organization.update_attribute(:email_address_username, organization.email_address_username.gsub(/\./, '-'))
      puts organization.email_address_username
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
