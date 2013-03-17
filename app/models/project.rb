class Project < ActiveRecord::Base
  attr_accessible :description, :name, :slug

  has_many :conversations, :order => "updated_at DESC"
  has_many :tasks, :order => "position"
  has_many :project_memberships
  has_many :members, :through => :project_memberships, :source => 'user'
  has_many :members_who_get_email, :through => :project_memberships, :source => 'user', :conditions => {project_memberships:{gets_email:true}}
  has_many :events, order: "created_at"

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  def to_param
    slug
  end

  def subject_tag
    slug[0..6]
  end

  def formatted_email_address
    "#{name} <#{slug}@multifyapp.com>"
  end

end
