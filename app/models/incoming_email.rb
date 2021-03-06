class IncomingEmail < ActiveRecord::Base

  serialize :params, IncomingEmail::Params

  belongs_to :creator, class_name: :User
  belongs_to :conversation
  belongs_to :organization
  belongs_to :message
  belongs_to :parent_message, class_name: :Message
  has_and_belongs_to_many :attachments
  has_and_belongs_to_many :groups

  default_scope { order :created_at => :asc }

  validates :params, presence: true

end
