class Project < ActiveRecord::Base
  attr_accessible :description, :name

  has_many :project_memberships
  has_many :members, :through => :project_memberships

end
