class ChangeOrganizationPlanDefaultToPaid < ActiveRecord::Migration
  def change
    change_column :organizations, :plan, :integer, default: 1, null: false
  end
end
