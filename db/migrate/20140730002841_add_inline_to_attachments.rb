class AddInlineToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :inline, :boolean, null: false, default: false
    add_index :attachments, [:inline]
  end
end
