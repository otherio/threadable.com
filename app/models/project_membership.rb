class ProjectMembership < ActiveRecord::Base

  attr_accessible :user, :project, :project_id, :user_id

  belongs_to :user
  belongs_to :project

end
