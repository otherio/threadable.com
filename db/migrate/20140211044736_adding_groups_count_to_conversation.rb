class AddingGroupsCountToConversation < ActiveRecord::Migration
  def up
    add_column :conversations, :groups_count, :integer, default: 0
    Conversation.reset_column_information
    Conversation.all.find_each do |conversation|
      conversation.update_attribute :groups_count, conversation.groups.count
    end
  end

  def down
    remove_column :conversations, :groups_count
  end
end
