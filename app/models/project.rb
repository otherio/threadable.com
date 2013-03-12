class Project < ActiveRecord::Base
  attr_accessible :description, :name, :slug

  has_many :conversations
  has_many :tasks, :order => "position"
  has_many :project_memberships
  has_many :members, :through => :project_memberships, :source => 'user'
  has_many :events, order: "created_at"

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true

  def to_param
    slug
  end

end
