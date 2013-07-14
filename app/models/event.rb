class Event < ActiveRecord::Base

  def type
    self.class.name.underscore.gsub('/','_').to_sym
  end

  serialize :content

  belongs_to :project
  belongs_to :user

  validates_presence_of :project
  validates_presence_of :user

end
