class ExternalAuthorization < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :provider, scope: :user
  validates_presence_of :provider
  validates_presence_of :token
end
