class AddPublicToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :public_signup, :boolean, default: false, null: false
  end
end
