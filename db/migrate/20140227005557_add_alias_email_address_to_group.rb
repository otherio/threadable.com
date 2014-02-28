class AddAliasEmailAddressToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :alias_email_address, :string, null: false, default: ''
  end
end
