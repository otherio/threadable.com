class CreateApiAccessTokens < ActiveRecord::Migration
  def change
    create_table :api_access_tokens do |t|
      t.integer  :user_id,    null: false
      t.string   :token,      null: false
      t.boolean  :active,     default: true
      t.datetime :created_at, null: false
    end
  end
end
