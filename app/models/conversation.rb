class Conversation < ActiveRecord::Base
  attr_accessible :project, :subject, :messages, :done

  belongs_to :project
  has_many :messages

  default_scope order('conversations.updated_at DESC')

  acts_as_url :subject, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  alias_method :to_param, :slug

  def task?
    false
  end

end
