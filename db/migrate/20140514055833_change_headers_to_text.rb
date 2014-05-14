class ChangeHeadersToText < ActiveRecord::Migration
  def up
    change_column :messages, :thread_index_header, :text
    change_column :messages, :thread_topic_header, :text
  end

  def down
    # This might break with long headers.
    change_column :messages, :thread_index_header, :string
    change_column :messages, :thread_topic_header, :string
  end
end
