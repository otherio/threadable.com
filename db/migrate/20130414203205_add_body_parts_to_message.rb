class AddBodyPartsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :stripped_plain, :text
    add_column :messages, :body_html, :text
    add_column :messages, :stripped_html, :text
    rename_column :messages, :body, :body_plain
  end
end
