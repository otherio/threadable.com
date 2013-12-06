class AddMessageIdHeaderIndex < ActiveRecord::Migration
  def change
    add_index "messages", ["message_id_header"], unique: true
  end
end
