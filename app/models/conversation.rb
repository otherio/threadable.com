class Conversation < ActiveRecord::Base

  belongs_to :organization
  belongs_to :creator, :class_name => 'User'
  has_many :messages, -> { order created_at: :asc }, dependent: :destroy
  has_many :events, -> { order "created_at" }, dependent: :destroy
  has_many :participants, ->{ uniq }, through: :messages, source: :creator
  has_and_belongs_to_many :muters, class_name: 'User', join_table: 'conversations_muters'
  has_and_belongs_to_many :followers, class_name: 'User', join_table: 'conversations_followers'
  has_many :conversation_groups, dependent: :destroy
  has_many :groups, ->{ where(conversation_groups: {active: true}) }, through: :conversation_groups, counter_cache: false
  has_many :groups_with_inactive, through: :conversation_groups, source: :group

  serialize :participant_names_cache, Array
  serialize :group_ids_cache, Array
  serialize :muter_ids_cache, Array
  serialize :follower_ids_cache, Array

  default_scope { order('conversations.updated_at DESC') }

  scope :with_slug, ->(slug){ where(slug: slug).limit(1) }
  scope :task,      ->{ where(type: 'Task') }
  scope :not_task,  ->{ where(type: nil) }
  scope :untrashed, ->{ where('trashed_at IS NULL') }
  scope :trashed,   ->{ where('trashed_at IS NOT NULL') }

  scope :muted_by, ->(user_id){
    joins('LEFT JOIN conversations_muters AS m ON m.conversation_id = conversations.id').where('m.user_id = ?', user_id)
  }

  scope :not_muted_by, ->(user_id){
    user_id = Conversation.sanitize(user_id)
    joins("LEFT JOIN conversations_muters AS m ON m.conversation_id = conversations.id AND m.user_id = #{user_id}").where('m.user_id IS NULL')
  }

  scope :followed_by, ->(user_id){
    joins('LEFT JOIN conversations_followers AS f ON f.conversation_id = conversations.id').where('f.user_id = ?', user_id)
  }

  scope :not_followed_by, ->(user_id){
    user_id = Conversation.sanitize(user_id)
    joins("LEFT JOIN conversations_followers AS f ON f.conversation_id = conversations.id AND f.user_id = #{user_id}").where('f.user_id IS NULL')
  }

  scope :accessible_to_user, ->(user_id){
    user_id = Conversation.sanitize(user_id)
    joins('LEFT JOIN conversation_groups AS scope_conversation_groups ON conversations.id = scope_conversation_groups.conversation_id and scope_conversation_groups.active = \'t\'').
    joins('LEFT JOIN groups AS scope_groups ON scope_groups.id = scope_conversation_groups.group_id and scope_groups.private = \'t\'').
    joins('LEFT JOIN group_memberships ON scope_conversation_groups.group_id = group_memberships.group_id').
    where('((group_memberships.user_id = ? and scope_conversation_groups.active = \'t\') or scope_groups.id is null)', user_id).
    group('conversations.id')
  }

  scope :in_open_groups, ->{
    joins('INNER JOIN conversation_groups AS scope_conversation_groups ON conversations.id = scope_conversation_groups.conversation_id and scope_conversation_groups.active = \'t\'').
    joins('INNER JOIN groups AS scope_groups ON scope_groups.id = scope_conversation_groups.group_id and scope_groups.private = \'f\'')
  }

  scope :for_user, ->(user_id){
    user_id = Conversation.sanitize(user_id)
    joins('LEFT JOIN conversation_groups AS scope_conversation_groups ON conversations.id = scope_conversation_groups.conversation_id and scope_conversation_groups.active = \'t\'').
    joins("LEFT JOIN group_memberships ON scope_conversation_groups.group_id = group_memberships.group_id AND group_memberships.user_id = #{user_id}").
    joins("LEFT JOIN conversations_followers ON conversations_followers.conversation_id = conversations.id AND conversations_followers.user_id = #{user_id}").
    where('group_memberships.user_id is not null or (conversations.private_cache = \'f\' AND conversations_followers.user_id is not null)', user_id).
    group('conversations.id')
  }

  scope :for_user_with_private, ->(user_id){
    user_id = Conversation.sanitize(user_id)
    joins('LEFT JOIN conversation_groups AS scope_conversation_groups ON conversations.id = scope_conversation_groups.conversation_id and scope_conversation_groups.active = \'t\'').
    joins("LEFT JOIN group_memberships ON scope_conversation_groups.group_id = group_memberships.group_id AND group_memberships.user_id = #{user_id}").
    joins("LEFT JOIN conversations_followers ON conversations_followers.conversation_id = conversations.id AND conversations_followers.user_id = #{user_id}").
    where('group_memberships.user_id is not null or conversations_followers.user_id is not null', user_id).
    group('conversations.id')
  }

  scope :with_last_message_at, ->(time) {
    start = time.midnight
    stop = start + 1.day
    where('last_message_at BETWEEN ? AND ?', start, stop)
  }

  acts_as_url(:subject,
    url_attribute:                        :slug,
    only_when_blank:                      true,
    sync_url:                             true,
    enforce_uniqueness_on_sti_base_class: true,
    limit:                                50,
  )

  alias_method :to_param, :slug

  validates :organization_id, presence: true
  validates :subject,         presence: true
  validates :slug,            presence: true
  validate :validate_slug_does_not_collide_with_existing_route

  def type
    read_attribute(:type) || 'Conversation'
  end

  def task?
    type == 'Task'
  end

  def convert_to_task!
    update_attribute(:type, 'Task')
    ::Task.find(id)
  end

  def convert_to_conversation!
    self
  end

  private

  # this is crazy pants... sorry - Jared
  def validate_slug_does_not_collide_with_existing_route
    # return true unless organization.present? && to_param.present?
    # valid_slug = false

    # until valid_slug
    #   path = Rails.application.routes.url_helpers.organization_conversation_path(organization, self)

    #   begin
    #     route = Rails.application.routes.recognize_path(path)
    #   rescue ActionController::RoutingError
    #     next
    #   end

    #   expected_route = {
    #     action: "show",
    #     controller: "conversations",
    #     organization_id: organization.to_param,
    #     id: to_param,
    #   }

    #   if route == expected_route
    #     valid_slug = true
    #   else
    #     original_slug = slug
    #     n = 1
    #     self.slug = "#{slug}-#{n}"
    #     while self.class.where(slug: self.slug).exists?
    #       n = n + 1
    #       self.slug = "#{original_slug}-#{n}"
    #     end
    #   end

    # end
  end

end
