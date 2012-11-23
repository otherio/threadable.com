class ProjectMembership < ActiveRecord::Base
  attr_accessible :project_id, :user_id

  has_one :user
  has_one :project

end
