class Event < ActiveRecord::Base

  serialize :content, Hash

  belongs_to :project
  belongs_to :user

  validates_presence_of :project
  validates_presence_of :user

  default_scope { order :created_at => :asc }

end
