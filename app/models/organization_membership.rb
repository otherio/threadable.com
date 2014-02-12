class OrganizationMembership < ActiveRecord::Base

  # WARNING! you can only append to this list. The indices are meaningful! - Jared
  UNGROUPED_MAIL_DELIVERY_VALUES = [
    :no_mail,
    :each_message,
    :in_summary,
  ].freeze

  belongs_to :organization
  belongs_to :user
  has_many :email_addresses, through: :user

  scope :who_get_email, ->{ where(gets_email: true) }

  scope :for_organization, ->(organization_id){
    where(organization_id: organization_id)
  }

  scope :who_have_not_muted, ->(conversation_ids){
    conversation_ids = Array(conversation_ids).map(&:to_i).join(',')
    joins("LEFT JOIN conversations_muters m ON m.user_id = organization_memberships.user_id AND m.conversation_id in (#{conversation_ids})").
    where('m.user_id IS NULL')
  }

  scope :in_groups, ->(group_ids){
    group_ids = Array(group_ids).map(&:to_i).join(',')
    joins("INNER JOIN group_memberships ON group_memberships.group_id in (#{group_ids})").
    where('group_memberships.user_id = organization_memberships.user_id')
  }

  scope :who_get_ungrouped, -> {
    where(ungrouped_mail_delivery: UNGROUPED_MAIL_DELIVERY_VALUES.index(:each_message))
  }

  validates_inclusion_of :gets_email, :in => [ true, false ]
  validates_inclusion_of :ungrouped_mail_delivery, :in => UNGROUPED_MAIL_DELIVERY_VALUES

  def subscribed?
    self.gets_email?
  end

  def subscribed= value
    self.gets_email = value
  end

  def subscribed_changed?
    self.gets_email_changed?
  end

  def ungrouped_mail_delivery
    UNGROUPED_MAIL_DELIVERY_VALUES[super]
  end

  def ungrouped_mail_delivery= value
    value = value.to_sym
    index = UNGROUPED_MAIL_DELIVERY_VALUES.index(value)
    index or raise ArgumentError, "expected #{value.inspect} to be one of #{UNGROUPED_MAIL_DELIVERY_VALUES.inspect}"
    super(index)
  end

end
