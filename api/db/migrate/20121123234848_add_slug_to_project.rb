class AddSlugToProject < ActiveRecord::Migration
  def change
  	add_column :projects, :slug, :string, default: 'slug', null: false
    add_index :projects, :slug, unique: true
	end
end
