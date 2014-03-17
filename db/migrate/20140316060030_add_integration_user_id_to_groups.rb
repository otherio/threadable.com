class AddIntegrationUserIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :integration_user_id, :integer
  end
end
