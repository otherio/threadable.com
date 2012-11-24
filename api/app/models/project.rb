class Project < ActiveRecord::Base
  attr_accessible :description, :name, :slug

  has_many :project_memberships
  has_many :members, :through => :project_memberships

  has_many :tasks

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20
end
