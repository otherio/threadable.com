class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string  :url
      t.string  :filename
      t.string  :mimetype
      t.integer :size
      t.boolean :writeable
      t.timestamps
    end

    create_table :attachments_messages, :id => false do |t|
      t.integer :message_id
      t.integer :attachment_id
    end
    add_index :attachments_messages, :message_id
  end
end
