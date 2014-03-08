class AddIntegrationAndTrelloBoardToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :integration_type, :string
    add_column :groups, :integration_params, :string
  end
end
