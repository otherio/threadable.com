class AddUniqueIdToExternalAuthorizations < ActiveRecord::Migration
  def change
    add_column :external_authorizations, :unique_id, :string, null: false, default: ''
    add_index :external_authorizations, [:unique_id, :provider]
  end
end
