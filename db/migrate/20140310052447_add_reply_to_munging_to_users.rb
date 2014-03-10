class AddReplyToMungingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :munge_reply_to, :boolean, default: true
  end
end
