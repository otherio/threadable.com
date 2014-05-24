class AddRefreshTokenToExternalAuthorizations < ActiveRecord::Migration
  def change
    add_column :external_authorizations, :refresh_token, :string
  end
end
