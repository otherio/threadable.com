class Conversation < ActiveRecord::Base

  attr_accessible :project, :creator, :subject, :messages, :done

  belongs_to :project
  belongs_to :creator, class_name: 'User'
  has_many :messages, order: 'messages.created_at ASC'
  has_many :events
  has_many :participants, through: :messages, source: :user, uniq: true, order: nil

  default_scope order('conversations.updated_at DESC')

  acts_as_url :subject, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  alias_method :to_param, :slug

  validates_presence_of :subject
  validates_presence_of :creator
  after_create :create_created_event!

  def task?
    false
  end

  private

  def create_created_event!
    self.class::CreatedEvent.create!(
      conversation: self,
      project: project,
      user: creator,
    )
  end

end

require_dependency "#{Rails.root}/app/models/conversation/event"
