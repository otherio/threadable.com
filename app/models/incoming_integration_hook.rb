class IncomingIntegrationHook < ActiveRecord::Base

  serialize :params, IncomingIntegrationHook::Params

  belongs_to :creator, class_name: :User
  belongs_to :conversation
  belongs_to :organization
  belongs_to :message
  belongs_to :group
  has_and_belongs_to_many :attachments

  default_scope { order :created_at => :asc }

  validates :params,   presence: true
  validates :provider, presence: true

end
