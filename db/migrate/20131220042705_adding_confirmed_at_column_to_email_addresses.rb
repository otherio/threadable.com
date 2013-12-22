class AddingConfirmedAtColumnToEmailAddresses < ActiveRecord::Migration
  def change
    add_column "email_addresses", "confirmed_at", "datetime"
    EmailAddress.update_all(confirmed_at: Time.now)
  end
end
