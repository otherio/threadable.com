class Conversation < ActiveRecord::Base
  belongs_to :project
  has_many :messages
  attr_accessible :slug, :subject
end
