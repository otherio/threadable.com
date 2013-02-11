class AddAvatarUrlToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :avatar_url
    end
  end
end
