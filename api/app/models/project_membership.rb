class ProjectMembership < ActiveRecord::Base

  attr_accessible :user, :project, :project_id, :user_id

  belongs_to :user
  belongs_to :project

  scope :read_only, where('project_memberships.read_only = 1')

end
