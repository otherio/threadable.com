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

  validates_presence_of :subject, :creator, :slug
  validate :validate_slug_does_not_collide_with_existing_route
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

  # this is crazy pants... sorry - Jared
  def validate_slug_does_not_collide_with_existing_route
    return true unless project.present? && to_param.present?
    valid_slug = false

    until valid_slug
      path = Rails.application.routes.url_helpers.project_conversation_path(project, self)

      begin
        route = Rails.application.routes.recognize_path(path)
      rescue ActionController::RoutingError
        next
      end

      expected_route = {
        action: "show",
        controller: "conversations",
        project_id: project.to_param,
        id: to_param,
      }

      if route == expected_route
        valid_slug = true
      else
        original_slug = slug
        n = 1
        self.slug = "#{slug}-#{n}"
        while self.class.where(slug: self.slug).exists?
          n = n + 1
          self.slug = "#{original_slug}-#{n}"
        end
      end

    end
  end


end

require_dependency "#{Rails.root}/app/models/conversation/event"
