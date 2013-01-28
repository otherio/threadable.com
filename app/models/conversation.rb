class Conversation < ActiveRecord::Base
  belongs_to :project
  has_many :messages
  attr_accessible :subject
  acts_as_url :subject, :url_attribute => :slug, :only_when_blank => true, :sync_url => true
end
