class AddDomainToExternalAuthorizations < ActiveRecord::Migration
  def change
    add_column :external_authorizations, :domain, :string
  end
end
