class AddWebhookUrlToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :webhook_url, :string, null: false, default: ''
  end
end
