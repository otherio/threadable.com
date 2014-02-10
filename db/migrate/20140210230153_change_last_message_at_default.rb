class ChangeLastMessageAtDefault < ActiveRecord::Migration
  def up
    execute 'alter table conversations alter column last_message_at set default now()'
  end

  def down
  end
end
