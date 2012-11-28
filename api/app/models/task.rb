class Task < ActiveRecord::Base
  attr_accessible :name, :slug, :project_id, :done, :due_at

  belongs_to :project

  has_many :doers
  has_many :follower

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 40
end
