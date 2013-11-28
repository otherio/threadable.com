class AddingDateToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :date_header, :string
  end
end
