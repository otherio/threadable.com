class ChangeHoldMessagesToNonMemberPosting < ActiveRecord::Migration
  def up
    add_column :groups, :non_member_posting, :integer, null: false, default: 1
    execute("update groups set non_member_posting = 0 where hold_messages = 'f'")
    remove_column :groups, :hold_messages
  end

  def down
    add_column :groups, :hold_messages, :boolean, null: false, default: true
    execute("update groups set hold_messages = 'f' where non_member_posting = 0")
    remove_column :groups, :non_member_posting
  end
end
