class AddPlanToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :plan, :integer, default: 0, null: false
  end
end
