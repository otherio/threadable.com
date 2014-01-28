class AddIndicesToSlugs < ActiveRecord::Migration
  def change
    add_index :conversations, :slug
    add_index :groups, :email_address_tag
  end
end
