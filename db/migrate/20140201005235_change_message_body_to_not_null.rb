class ChangeMessageBodyToNotNull < ActiveRecord::Migration
  def up
    change_column :messages, :body_html, :text, null: false, default: ''
    change_column :messages, :body_plain, :text, null: false, default: ''
  end
  def down
    change_column :messages, :body_html, :text, null: true, default: ''
    change_column :messages, :body_plain, :text, null: true
  end
end
