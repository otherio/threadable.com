class Organization < ActiveRecord::Base

  # WARNING! you can only append to this list. The indices are meaningful!
  PLANS = [
    :free,
    :paid,
  ].freeze

  has_many :conversations, dependent: :destroy
  has_many :messages, through: :conversations
  has_many :tasks, -> { order "position" }, class_name: 'Task'
  has_many :organization_memberships, dependent: :destroy
  has_many :memberships, class_name: 'OrganizationMembership', dependent: :destroy
  has_many :members, :through => :memberships, :source => :user do
    def who_get_email
      where organization_memberships: {active: true, gets_email: true, confirmed: true}
    end

    def active
      where organization_memberships: {active: true}
    end
  end
  has_many :members_who_get_email, -> { where organization_memberships: {gets_email:true} }, :through => :organization_memberships, :source => :user
  has_many :events, -> { order "created_at" }, dependent: :destroy
  has_many :incoming_emails, -> { order "created_at" }, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :email_domains, autosave: true, validate: true

  belongs_to :google_user, class_name: 'User'

  scope :with_members, ->{ includes(:organization_memberships).where('organization_memberships.id IS NOT NULL').references(:organization_memberships) }
  scope :without_members, ->{ includes(:organization_memberships).where(organization_memberships:{id:nil}).references(:organization_memberships) }

  scope :with_member, -> member do
    includes(:members).
    where(organization_memberships: {user_id: member.id}).
    references(:organization_memberships)
  end

  # makes free_plans and paid_plans scopes.
  # maybe useful, but don't uncomment without making the required index.
  #
  # PLANS.each do |plan|
  #   scope "#{plan.to_s}_plans".to_sym, -> { where(plan: plan) }
  # end

  validates_inclusion_of :plan, :in => PLANS
  validates_presence_of :name, :slug, :email_address_username
  validates_uniqueness_of :slug, :email_address_username
  validates_format_of :subject_tag, with: /\A([\w \&\.\'\-+]+|)\z/
  validates_format_of :email_address_username, with: /\A[a-z0-9_-]+\z/
  validate :username_special_characters

  acts_as_url :short_name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :limit => 50

  def name= name
    self.short_name = name if short_name.blank?
    super
  end

  def email_address_username= email_address_username
    super email_address_username.to_s.downcase
  end

  def short_name
    self.short_name = name if subject_tag.blank?
    subject_tag
  end

  def short_name= short_name
    short_name = short_name.presence || name
    return if short_name.blank?
    short_name = short_name.gsub(/[\W]+/, ' ').strip
    self.subject_tag = short_name
    self.slug = nil
    self.email_address_username = short_name.downcase.gsub(/\W+/,'-')
  end

  def plan
    PLANS[super]
  end

  def plan= value
    value = value.to_sym
    index = PLANS.index(value)
    index or raise ArgumentError, "expected #{value.inspect} to be one of #{PLANS.inspect}"
    super(index)
  end

  def to_param
    slug
  end

  def username_special_characters
    if email_address_username.present? && email_address_username =~ /--/
      errors.add :email_address_username, "is invalid"
    end
  end

end
