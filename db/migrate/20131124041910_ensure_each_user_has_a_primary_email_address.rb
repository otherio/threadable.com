class EnsureEachUserHasAPrimaryEmailAddress < ActiveRecord::Migration
  def up
    User.find_in_batches do |users|
      users.each do |user|
        next if user.email_addresses.primary.first.present?
        user.email_addresses.first.update(primary: true)
      end
    end
  end

  def down
  end
end
