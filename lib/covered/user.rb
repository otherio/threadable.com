class Covered::User < ActiveRecord::Base

  extend SimpleModelName

  include Password

  has_many :email_addresses
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :messages
  has_many :project_messages, through: :projects, source: :messages
  has_many :conversations, ->{ uniq }, through: :projects

  has_and_belongs_to_many :tasks, join_table: 'task_doers'

  validates :name, presence: true
  validates :email, presence: true
  validates_associated :email_addresses
  validate :validate_email_address_is_not_already_taken!

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
  alias_method :to_param, :slug

  default_scope -> { includes(:email_addresses) }

  scope :with_email, ->(address){
    readonly(false). \
    joins(:email_addresses). \
    where(email_addresses: {address: address}). \
    limit(1)
  }


  scope :confirmed, ->{ where('users.confirmed_at IS NOT NULL') }
  scope :not_confirmed, ->{ where(confirmed_at: nil) }

  def web_enabled?
    encrypted_password.present?
  end

  def requires_setup?
    !web_enabled?
  end

  def primary_email_address
    email_addresses.find(&:primary?) || email_addresses.first
  end

  def email
    primary_email_address.try(:address)
  end

  def email= address
    (primary_email_address || email_addresses.build(user:self)).address = address
  end

  def email_changed?
    primary_email_address.present? && primary_email_address.changed?
  end

  def as_json options={}
    options[:methods] ||= 'email'
    super
  end

  def formatted_email_address
    "#{name} <#{email}>"
  end

  def avatar_url
    read_attribute(:avatar_url) || gravatar_url
  end

  def confirm!
    update_attribute(:confirmed_at, Time.now)
  end

  def confirmed?
    confirmed_at.present?
  end

  private

  def gravatar_url
    # change this when we have a default image other than gravatar's
    #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
    gravatar_id = Digest::MD5.hexdigest(email.downcase) if email.present?
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=retro"
  end

  def validate_email_address_is_not_already_taken!
    return if primary_email_address.nil?
    return if primary_email_address.errors[:address].blank?
    if primary_email_address.errors[:address].include? "has already been taken"
      errors.add(:email, "has already been taken")
    end
  end

end
