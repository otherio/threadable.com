class CreateExternalAuthorizations < ActiveRecord::Migration
  def change
    create_table :external_authorizations do |t|
      t.integer :user_id
      t.string  :provider
      t.string  :token
      t.string  :secret
      t.string  :name
      t.string  :email_address
      t.string  :nickname
      t.string  :url
      t.timestamps
    end
    add_index :external_authorizations, [:user_id, :provider], unique: true
  end
end
