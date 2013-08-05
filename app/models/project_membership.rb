class ProjectMembership < ActiveRecord::Base

  belongs_to :user
  belongs_to :project

  scope :that_get_email, ->{ where(gets_email: true) }

end
