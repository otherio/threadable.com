class User < ActiveRecord::Base
  include PgSearch

  before_create :default_values

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :omniauthable, :omniauth_providers => [:clef]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :slug, :password, :password_confirmation, :remember_me, :tasks, :avatar_url, :provider, :uid

  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :messages
  has_many :conversations, through: :projects, :uniq => true

  has_and_belongs_to_many :tasks, join_table: 'task_doers'

  # make sure the user has an auth token
  before_save :ensure_authentication_token

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
  alias_method :to_param, :slug

  pg_search_scope :search_by_identity, :against => [:email, :name]

  def password_required= password_required
    @password_required = password_required
  end

  private

  def password_required?
    @password_required.nil? ? super : @password_required
  end

  def default_values
    unless self.avatar_url
      #default_avatar_url = URI.join(root_url, 'images/default-avatar.png').to_s

      # change this when we have a default image other than gravatar's
      #"http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=#{CGI.escape(default_avatar_url)}"
      gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
      self.avatar_url = "http://gravatar.com/avatar/#{gravatar_id}.png?s=48"
    end
    true
  end

  def self.find_for_clef_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid.to_s).first
    unless user
      user = User.create(
        name:     auth.extra.raw_info.name,
        provider: auth.provider,
        uid:      auth.uid,
        email:    auth.info.email,
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end

end
