class User < ActiveRecord::Base

  include Password

  has_many :email_addresses, autosave: true
  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :messages
  has_many :project_messages, through: :projects, source: :messages
  has_many :conversations, ->{ uniq }, through: :projects

  has_and_belongs_to_many :tasks, join_table: 'task_doers'

  validates :name, presence: true
  validates :email_address, presence: true
  validates_associated :email_addresses

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
  alias_method :to_param, :slug

  default_scope -> { includes(:email_addresses) }

  scope :with_email_address, ->(email_address){
    readonly(false). \
    joins(:email_addresses). \
    where(email_addresses: {address: email_address}). \
    limit(1)
  }

  def self.find_by_email_address email_address
    with_email_address(email_address).first
  end

  def self.find_by_email_address! email_address
    with_email_address(email_address).first!
  end


  scope :confirmed, ->{ where('users.confirmed_at IS NOT NULL') }
  scope :not_confirmed, ->{ where(confirmed_at: nil) }

  # this makes user objects look like Covered::User objects
  def user_id
    id
  end

  def email_address= email_address
    email_addresses.build(
      user: self,
      address: email_address,
      primary: true
    )
  end

  def email_address
    email_addresses.reverse.find(&:primary?).try(:address)
  end

  def avatar_url
    read_attribute(:avatar_url) || gravatar_url
  end

  def confirmed?
    confirmed_at.present?
  end

  private

  def gravatar_url
    # change this when we have a default image other than gravatar's
    #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
    return unless email_address.present?
    gravatar_id = Digest::MD5.hexdigest(email_address.downcase)
    "//gravatar.com/avatar/#{gravatar_id}.png?s=48&d=retro"
  end

end
