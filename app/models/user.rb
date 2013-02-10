class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :slug, :password, :password_confirmation, :remember_me, :tasks

  has_many :project_memberships
  has_many :projects, :through => :project_memberships
  has_many :messages
  has_many :conversations, through: :projects, :uniq => true

  has_and_belongs_to_many :tasks, join_table: 'task_doers'



  # make sure the user has an auth token
  before_save :ensure_authentication_token

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
  alias_method :to_param, :slug
end
