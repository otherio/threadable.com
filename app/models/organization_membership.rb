class OrganizationMembership < ActiveRecord::Base

  # Do not change these values! If you need to, add additional integers to the list - Jared
  UNGROUPED_CONVERSATIONS_VALUES = {
    no_ungrouped_conversation_mail:     0,
    ungrouped_conversation_messages:    1,
    ungrouped_conversations_in_summary: 2,
  }.freeze

  belongs_to :organization
  belongs_to :user
  has_many :email_addresses, through: :user

  scope :who_get_email, ->{ where(gets_email: true) }

  validates_presence_of :organization_id, :user_id
  validates_inclusion_of :gets_email, :in => [ true, false ]
  validates_inclusion_of :ungrouped_conversations, :in => UNGROUPED_CONVERSATIONS_VALUES.values

  def subscribed?
    gets_email?
  end

  def subscribe!
    update! gets_email: true
  end

  def unsubscribe!
    update! gets_email: false
  end

  UNGROUPED_CONVERSATIONS_VALUES.each do |state, value|
    scope "who_get_#{state}", ->{ where(ungrouped_conversations: value) }
    define_method("gets_#{state}?"){ ungrouped_conversations == value }
    define_method("gets_#{state}!"){ update! ungrouped_conversations: value }
  end


end
