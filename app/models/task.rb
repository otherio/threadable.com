class Task < ActiveRecord::Base
  attr_accessible :name, :slug, :project_id, :done, :due_at

  belongs_to :conversation
  has_one :project, through: :conversation

  has_and_belongs_to_many :doers, class_name: 'User', join_table: 'task_doers'
  # has_and_belongs_to_many :followers, class_name: 'User', join_table: 'task_followers'

  acts_as_url :name, :url_attribute => :slug, :only_when_blank => true, :sync_url => true, :length => 40
end
