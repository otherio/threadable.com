class AddTrustedToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :trusted, :boolean, default: false
  end
end
