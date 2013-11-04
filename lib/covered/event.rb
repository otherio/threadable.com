class Covered::Event < ActiveRecord::Base

  serialize :content, Hash

  belongs_to :project, :class_name => 'Covered::Project'
  belongs_to :user,    :class_name => 'Covered::User'

  validates_presence_of :project
  validates_presence_of :user

end
