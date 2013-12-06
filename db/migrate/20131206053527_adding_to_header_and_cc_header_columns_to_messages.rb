class AddingToHeaderAndCcHeaderColumnsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :to_header, :string
    add_column :messages, :cc_header, :string
  end
end
