class OrganizationMembership < ActiveRecord::Base

  # WARNING! you can only append to this list. The indices are meaningful! - Jared
  ROLES = [
    :member,
    :owner,
  ].freeze

  belongs_to :organization
  belongs_to :user
  has_many :email_addresses, through: :user

  scope :who_get_email, ->{ where(active: true, gets_email: true, confirmed: true) }

  scope :who_are_owners, ->{ where(role: ROLES.index(:owner)) }

  scope :active, ->{ where(active: true) }

  scope :for_organization, ->(organization_id){
    where(organization_id: organization_id)
  }

  scope :who_have_not_muted, ->(conversation_ids){
    conversation_ids = Array(conversation_ids).map(&:to_i).join(',')
    joins("LEFT JOIN conversations_muters m ON m.user_id = organization_memberships.user_id AND m.conversation_id in (#{conversation_ids})").
    where('m.user_id IS NULL')
  }

  scope :in_groups_without_summary_including_followers, ->(conversation_ids, group_ids){
    group_ids = Array(group_ids).map(&:to_i).join(',')
    conversation_ids = Array(conversation_ids).map(&:to_i).join(',')

    joins("LEFT JOIN group_memberships ON group_memberships.group_id in (#{group_ids})").
    joins("LEFT JOIN conversations_followers f ON f.user_id = organization_memberships.user_id AND f.conversation_id in (#{conversation_ids})").
    where("(group_memberships.user_id = organization_memberships.user_id AND group_memberships.summary = 'f') OR f.user_id IS NOT NULL")
  }

  ROLES.each do |role|
    scope role.to_s.pluralize.to_sym, -> { where(role: role) }
  end

  validates_inclusion_of :gets_email, :in => [ true, false ]
  validates_inclusion_of :confirmed, :in => [ true, false ]
  validates_inclusion_of :role, :in => ROLES

  def subscribed?
    self.gets_email?
  end

  def subscribed= value
    self.gets_email = value
  end

  def subscribed_changed?
    self.gets_email_changed?
  end

  def role
    ROLES[super]
  end

  def role= value
    value = value.to_sym
    index = ROLES.index(value)
    index or raise ArgumentError, "expected #{value.inspect} to be one of #{ROLES.inspect}"
    super(index)
  end

end
