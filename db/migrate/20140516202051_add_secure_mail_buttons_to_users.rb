class AddSecureMailButtonsToUsers < ActiveRecord::Migration
  def up
    add_column :users, :secure_mail_buttons, :boolean, default: false

    # if you've dismissed the welcome modal, you're probably a user
    # of the web interface. your buttons require login.
    User.where(dismissed_welcome_modal: true).each do |user|
      user.update_attributes(secure_mail_buttons: true)
    end
  end

  def down
    remove_column :users, :secure_mail_buttons
  end
end
