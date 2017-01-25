class AddSearchableToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :searchable, :boolean, default: false, null: false
    add_index :organizations, [:searchable]
  end
end
