class Covered::ProjectMembership < ActiveRecord::Base

  belongs_to :project, :class_name => 'Covered::Project'
  belongs_to :user,    :class_name => 'Covered::User'

  scope :that_get_email, ->{ where(gets_email: true) }

end
