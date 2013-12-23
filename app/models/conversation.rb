class Conversation < ActiveRecord::Base

  belongs_to :organization
  belongs_to :creator, :class_name => 'User'
  has_many :messages, -> { order created_at: :asc }, dependent: :destroy
  has_many :events, class_name: 'Conversation::Event'
  has_many :participants, ->{ uniq }, through: :messages, source: :creator
  has_and_belongs_to_many :muters, class_name: 'User', join_table: 'conversations_muters'
  has_many :recipients, ->(conversation){
    id = Conversation.sanitize(conversation.id) # shit is fucked up and bullshit - JarIan
    joins("LEFT JOIN conversations_muters q ON q.user_id = users.id AND q.conversation_id = #{id}").where('q.user_id IS NULL')
  },  through: :organization, class_name: 'User', source: 'members_who_get_email'

  def self.default_scope
    order('conversations.updated_at DESC')
  end
  scope :with_slug, ->(slug){ where(slug: slug).limit(1) }
  scope :task, ->{ where(type: 'Task') }
  scope :not_task, ->{ where(type: nil) }

  acts_as_url :subject, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  alias_method :to_param, :slug

  validates_presence_of :subject, :slug
  validate :validate_slug_does_not_collide_with_existing_route

  def task?
    type == 'Task'
  end

  private

  # this is crazy pants... sorry - Jared
  def validate_slug_does_not_collide_with_existing_route
    return true unless organization.present? && to_param.present?
    valid_slug = false

    until valid_slug
      path = Rails.application.routes.url_helpers.organization_conversation_path(organization, self)

      begin
        route = Rails.application.routes.recognize_path(path)
      rescue ActionController::RoutingError
        next
      end

      expected_route = {
        action: "show",
        controller: "conversations",
        organization_id: organization.to_param,
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
