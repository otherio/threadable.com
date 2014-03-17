class AddingHoldAllMessagesBooleanToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :hold_all_messages, :boolean, default: false, null: false
  end
end
