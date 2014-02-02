class ChangeFixtureEmailAddresses < ActiveRecord::Migration
  def up
    EmailAddress.all.each do |email_address|
      if email_address.address =~ /ucsd\.threadable\.io/
        new_address = email_address.address.gsub(/ucsd\.threadable\.io/, 'ucsd.example.com')
        email_address.update_column(:address, new_address)
        puts "updated #{new_address}"
      end
    end
  end

  def down
  end
end
