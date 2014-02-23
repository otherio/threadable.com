class AddingCurrentOrganizationIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :current_organization_id, :integer
  end
end
