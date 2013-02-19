class Event < ActiveRecord::Base

  belongs_to :project
  belongs_to :user

  attr_accessible :project, :user

end
