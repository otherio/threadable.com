class Task < ActiveRecord::Base
  attr_accessible :done, :due_at, :name

  belongs_to :project

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 40
end
