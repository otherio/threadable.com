class Event < ActiveRecord::Base

  belongs_to :project
  belongs_to :user

  attr_accessible :project
  attr_accessible :user

  validates_presence_of :project
  validates_presence_of :user

end
