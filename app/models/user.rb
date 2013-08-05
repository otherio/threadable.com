class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise(
    :database_authenticatable,
    :registerable,
    :confirmable,
    :recoverable,
    :rememberable,
    :trackable,
    :token_authenticatable,
    :omniauthable,
    :authentication_keys => [:email]
  )

  has_many :email_addresses
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :messages
  has_many :conversations, ->{ uniq }, through: :projects

  has_and_belongs_to_many :tasks, join_table: 'task_doers'

  validates_presence_of :name, :email
  validates_length_of   :password, allow_blank: true, minimum: 6, maximum: 128
  validates_associated  :email_addresses
  validate :validate_email_address_is_not_already_taken!

  with_options if: :password_required? do |o|
    o.validates_presence_of     :password
    o.validates_confirmation_of :password
  end

  # make sure the user has an auth token
  before_save :ensure_authentication_token

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
  alias_method :to_param, :slug

  default_scope -> { includes(:email_addresses) }

  scope :with_email, ->(address){
    joins(:email_addresses).where(email_addresses: {address: address}).limit(1)
  }

  class << self

    def find_for_authentication(conditions={})
      condititons = conditions.symbolize_keys
      email = conditions.delete(:email) || conditions.delete(:unconfirmed_email)
      return self.by_email(email).first if email.present?
      return self.where(condititons).first if condititons.present?
    end

    alias_method :find_first_by_auth_conditions, :find_for_authentication

    def send_confirmation_instructions(attributes={})
      confirmable = find_by_unconfirmed_email_with_errors(attributes) if reconfirmable
      confirmable.resend_confirmation_token if confirmable.present? && confirmable.persisted?
      confirmable
    end
  end

  def password_required!
    @password_required = true
  end

  def password_required?
    return @password_required if defined?(@password_required)
    encrypted_password.present?
  end

  def web_enabled?
    encrypted_password.present?
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

  private

  def gravatar_url
    # change this when we have a default image other than gravatar's
    #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
    gravatar_id = Digest::MD5.hexdigest(email.downcase) if email.present?
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=retro"
  end

  def self.find_for_database_authentication(user)
    where(email_addresses: {address: user[:email]}).first
  end

  def self.send_reset_password_instructions(attributes={})
    attributes.permit!
    user = with_email(attributes[:email]).first_or_initialize(attributes)
    user.send_reset_password_instructions if user.persisted?
    user
  end

  def validate_email_address_is_not_already_taken!
    return if primary_email_address.nil?
    return if primary_email_address.errors[:address].blank?
    if primary_email_address.errors[:address].include? "has already been taken"
      errors.add(:email, "has already been taken")
    end
  end

end
