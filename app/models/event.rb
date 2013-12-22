class Event < ActiveRecord::Base

  serialize :content, Hash

  belongs_to :organization
  belongs_to :user

  validates_presence_of :organization

  default_scope { order :created_at => :asc }

end
