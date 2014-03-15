class ChangeReplyToMungingDefault < ActiveRecord::Migration
  def up
  	change_column :users, :munge_reply_to, :boolean, :default => false
  end
  def down
  	change_column :users, :munge_reply_to, :boolean, :default => true
  end
end
