class Multify::Project < Multify::Resource

  extend Multify::Resource::WithSlug

  assignable_attributes :name, :description, :slug

  attribute :name,        String
  attribute :description, String
  attribute :slug,        String
  attribute :created_at,  Time
  attribute :updated_at,  Time

  def tasks
    Tasks.new(id) if persisted?
  end

end

require 'multify/project/tasks'
