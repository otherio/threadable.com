class AddBodyPartsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :stripped_plain, :text, default: ''
    add_column :messages, :body_html, :text, default: ''
    add_column :messages, :stripped_html, :text, default: ''
    rename_column :messages, :body, :body_plain

    Message.update_all "stripped_plain = body_plain"
  end
end
