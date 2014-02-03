class LowerCasingEmailAddresses < ActiveRecord::Migration
  def up
    EmailAddress.find_each do |email_address|
      email_address.update_attribute(:address, email_address.address.try(:downcase))
    end
  end
  def down
  end
end
