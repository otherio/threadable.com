class Conversation < ActiveRecord::Base
  attr_accessible :subject
  belongs_to :project
  has_many :messages
  acts_as_url :subject, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  def task?
    false
  end
end
