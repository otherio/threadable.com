class CreateDomains < ActiveRecord::Migration
  def change
    create_table :email_domains do |t|
      t.integer :organization_id
      t.string  :domain, null: false
      t.boolean :outgoing, default: false, null: false
    end

    add_index :email_domains, [:domain]
  end
end
