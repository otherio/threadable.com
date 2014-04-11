class AddThreadIndexAndThreadTopicToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :thread_index_header, :string, null: true
    add_column :messages, :thread_topic_header, :string, null: true
    add_index :messages, [:thread_index_header]
  end
end
