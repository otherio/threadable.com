class Group < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :name
  validates_presence_of :organization_id
  validates_uniqueness_of :name, scope: :organization
  validates_uniqueness_of :email_address_tag, scope: :organization
  validates_format_of :email_address_tag, with: /\A[0-9a-z-]+\z/
  validates_format_of :subject_tag, with: /\A([\w \&\.\'\-+]+|)\z/
  validates_exclusion_of :email_address_tag, in: ['task', 'everyone']
  validate :email_address_tag_special_characters
  validate :alias_email_address_is_an_email_address
  validate :webhook_url_is_a_url

  has_many :conversation_groups, dependent: :destroy
  has_many :conversations, -> { where(conversation_groups: {active:true}) }, through: :conversation_groups
  has_many :memberships, class_name: 'GroupMembership', dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :tasks,
    -> { where(conversation_groups: {active:true}).order("position") },
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

  private

  def email_address_tag_special_characters
    return unless email_address_tag.present? && email_address_tag =~ /--/
    errors.add :email_address_tag, "is invalid"
  end

  def alias_email_address_is_an_email_address
    return if alias_email_address.nil? || alias_email_address.empty?
    begin
      address = Mail::Address.new(alias_email_address)
      return if address.local.present? && address.domain.present?
    rescue Mail::Field::FieldError
    end
    errors.add :alias_email_address, "is invalid"
  end

  def webhook_url_is_a_url
    return if webhook_url.nil? || webhook_url.empty?
    begin
      uri = URI.parse(webhook_url)
      errors.add(:webhook_url, "cannot be a relative url")             if uri.relative?
      errors.add(:webhook_url, "must start with either http or https") if uri.scheme !~ %r{^https?$}
      errors.add(:webhook_url, "does not have a valid host")           if uri.host !~ /\w+\.\w+/
    rescue URI::InvalidURIError
      errors.add(:webhook_url, "is not a invalid url")
    end
  end

end
