class AddingHoldMessagesBooleanToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :hold_messages, :boolean, default: true
  end
end
