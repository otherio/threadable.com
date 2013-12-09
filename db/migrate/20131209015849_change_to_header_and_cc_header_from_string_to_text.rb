class ChangeToHeaderAndCcHeaderFromStringToText < ActiveRecord::Migration
  def up
    change_column :messages, :to_header, :text
    change_column :messages, :cc_header, :text
  end
  def down
    change_column :messages, :to_header, :string
    change_column :messages, :cc_header, :string
  end
end
