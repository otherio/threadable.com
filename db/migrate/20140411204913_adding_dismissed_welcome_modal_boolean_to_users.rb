class AddingDismissedWelcomeModalBooleanToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dismissed_welcome_modal, :boolean, null: false, default: false
  end
end
