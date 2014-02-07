class Group < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :name
  validates_presence_of :organization_id
  validates_uniqueness_of :name, scope: :organization
  validates_uniqueness_of :email_address_tag, scope: :organization
  validates_format_of :name, with: /\A[0-9A-Za-z -]+\z/
  validates_format_of :email_address_tag, with: /\A[0-9a-z-]+\z/
  validates_format_of :subject_tag, with: /\A([\w \&\-+]+|)\z/
  validates_exclusion_of :email_address_tag, in: ['task', 'everyone']
  validate :email_address_tag_special_characters

  has_many :conversation_groups, dependent: :destroy
  has_many :conversations, -> { where(conversation_groups: {active:true}) }, through: :conversation_groups
  has_many :group_members, class_name: 'GroupMembership', dependent: :destroy
  has_many :members, through: :group_members, source: 'user'
  has_many :tasks,
    -> { order "position" },
    class_name: 'Task',
    through: :conversation_groups,
    source: :conversation

  def name= name
    unless email_address_tag.present?
      write_attribute(:email_address_tag, name.gsub(/[^0-9A-Za-z-]+/, '-').strip.downcase)
    end
    super
  end

  def to_param
    email_address_tag
  end

  def slug
    email_address_tag
  end

  def email_address_tag_special_characters
    if email_address_tag.present? && email_address_tag =~ /--/
      errors.add :email_address_tag, "is invalid"
    end
  end

end
