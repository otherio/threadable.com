class TrustExistingOrganizations < ActiveRecord::Migration
  def up
    ::Organization.update_all(trusted: true)
  end

  def down
  end
end
