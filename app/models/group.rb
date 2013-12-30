class Group < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :name
  validates_presence_of :organization_id
  validates_uniqueness_of :name, scope: :organization
  validates_uniqueness_of :email_address_tag, scope: :organization
  validates_format_of :name, with: /\A[0-9A-Za-z -]+\z/
  validates_format_of :email_address_tag, with: /\A[0-9a-z-]+\z/
  validates_exclusion_of :email_address_tag, in: ['task', 'everyone']

  has_many :conversation_groups
  has_many :conversations, through: :conversation_groups
  has_many :group_members, class_name: 'GroupMembership'
  has_many :members, through: :group_members, source: 'user'
  has_many :tasks, -> { order "position" }, class_name: 'Task'

  def name= name
    write_attribute(:email_address_tag, name.gsub(/[^0-9A-Za-z-]+/, '-').strip.downcase)
    super
  end

  def email_address_tag= email_address_tag
  end

  def to_param
    email_address_tag
  end

end
