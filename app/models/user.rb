class User < ActiveRecord::Base

  before_create :default_values

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
    :omniauth_providers => [:clef],
    :authentication_keys => [:email]
  )

  # Setup accessible (or protected) attributes for your model
  attr_accessible(
    :name,
    :email,
    :slug,
    :password,
    :password_confirmation,
    :remember_me,
    :tasks,
    :avatar_url,
    :provider,
    :uid,
    :email_addresses
  )

  has_many :email_addresses
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :messages
  has_many :conversations, through: :projects, :uniq => true

  has_and_belongs_to_many :tasks, join_table: 'task_doers'

  validates_presence_of     :name, :email
  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, allow_blank: true, minimum: 6, maximum: 128
  validate                  :validate_email_is_unique

  # make sure the user has an auth token
  before_save :ensure_authentication_token

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
  alias_method :to_param, :slug

  default_scope includes(:email_addresses)

  scope :by_email, ->(address){
    joins(:email_addresses).where(email_addresses: {address: address}).limit(1)
  }

  def self.find_by_email(email)
    by_email(email).first
  end

  def self.find_by_email!(email)
    by_email(email).first!
  end

  def self.find_or_initialize_by_email(attributes)
    if attributes.is_a?(Hash)
      email = attributes[:email]
    else
      email = attributes
      attributes = {}
    end
    user = find_by_email(email) || new(email: email)
    user.attributes = attributes
    user
  end

  def password_required= password_required
    @password_required = password_required
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

  private

  def password_required?
    return @password_required unless @password_required.nil?
    confirmed?
  end

  def default_values
    self.avatar_url ||= gravatar_url
  end

  def gravatar_url
    # change this when we have a default image other than gravatar's
    #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
    gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=retro" if email.present?
  end

  def validate_email_is_unique
    if email_addresses.any?(&:has_taken_error?)
      errors.add(:email, I18n.t('activerecord.errors.messages.taken'))
    end
  end

  def self.find_for_database_authentication(user)
    where(email_addresses: {address: user[:email]}).first
  end

  def self.send_reset_password_instructions(attributes={})
    user = find_or_initialize_by_email(attributes)
    user.send_reset_password_instructions if user.persisted?
    user
  end

  def self.find_for_clef_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid.to_s).first
    user or User.transaction do
      user = User.create(
        name:     auth.extra.raw_info.name,
        provider: auth.provider,
        uid:      auth.uid,
        password: Devise.friendly_token[0,20]
      )
      user.email_addresses.create(address:auth.info.email)
    end
    user
  end

end
