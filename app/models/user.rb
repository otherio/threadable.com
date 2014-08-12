class User < ActiveRecord::Base

  include AlgoliaSearch
  algoliasearch do
    attribute(:id, :name, :slug)

    attribute :email_addresses do
      email_addresses.map(&:address).join(' ')
    end

    attributesToIndex %w(
      id
      name
      slug
      email_addresses
    )

  end

  include Password

  # NOTE! If you add an association here please update Threadable::User::MergeInto - Jared
  has_many :email_addresses, autosave: true, validate: true
  has_many :organization_memberships, dependent: :destroy
  has_many :organizations, :through => :organization_memberships
  has_many :group_memberships, dependent: :destroy
  has_many :groups, :through => :group_memberships
  has_many :messages
  has_many :organization_messages, through: :organizations, source: :messages
  has_many :conversations, ->{ uniq }, through: :organizations
  has_many :external_authorizations
  has_many :events
  has_many :api_access_tokens

  has_many :task_doers
  has_and_belongs_to_many :tasks, join_table: 'task_doers'

  accepts_nested_attributes_for :email_addresses

  validates :name, presence: true
  validates :email_address, presence: true
  validates_associated :email_addresses

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :limit => 20
  alias_method :to_param, :slug

  default_scope { includes(:email_addresses) }

  scope :with_email_address, ->(email_address){
    readonly(false). \
    joins(:email_addresses). \
    where(email_addresses: {address: email_address.downcase})
  }

  def self.find_by_email_address email_address
    with_email_address(email_address).first
  end

  def self.find_by_email_address! email_address
    with_email_address(email_address).first!
  end


  scope :confirmed, ->{ where('users.confirmed_at IS NOT NULL') }
  scope :not_confirmed, ->{ where(confirmed_at: nil) }

  # this makes user objects look like Threadable::User objects
  def user_id
    id
  end

  def api_access_token
    api_access_tokens.active.first
  end

  def email_address= address
    if email_address = EmailAddress.where(address: address.downcase, user_id: nil).first
      primary_email_address && primary_email_address.update_attribute(:primary, false)
      email_address.primary = true
      email_addresses << email_address
    else
      email_addresses.build(
        user: self,
        address: address.downcase,
        primary: new_record?,
        confirmed_at: nil,
      )
    end
  end

  def primary_email_address
    email_addresses.find(&:primary?)
  end

  def email_address
    primary_email_address.try(:address)
  end

  def email_addresses_as_string
    email_addresses.map(&:address).join("\n")
  end

  def avatar_url
    read_attribute(:avatar_url) || gravatar_url
  end

  private

  def gravatar_url
    # change this when we have a default image other than gravatar's
    #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
    return unless email_address.present?
    gravatar_id = Digest::MD5.hexdigest(email_address.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?s=70&d=retro"
  end

end
