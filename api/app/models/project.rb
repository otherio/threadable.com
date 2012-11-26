class Project < ActiveRecord::Base

  attr_accessible :description, :name, :slug

  has_many :project_memberships

  has_many :members,    
    :through => :project_memberships,
    :source => :user

  has_many :follower,   
    :through => :project_memberships, 
    :source => :user,
    :conditions => "gets_email = 1"

  has_many :moderators, 
    :through => :project_memberships, 
    :source => :user,
    :conditions => "moderator = 1" 

  has_many :tasks

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 20

end
