class AddAliasAddressToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :alias_address, :string
  end
end
