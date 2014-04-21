class AddShowMailButtonsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :show_mail_buttons, :boolean, default: true
  end
end
