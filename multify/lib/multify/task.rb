class Multify::Task < Multify::Resource

  extend Multify::Resource::WithSlug

  assignable_attributes :name, :slug, :project_id, :done, :due_at

  attribute :name,       String
  attribute :slug,       String
  attribute :project_id, Integer
  attribute :done,       Boolean
  attribute :due_at,     Time
  attribute :created_at, Time
  attribute :updated_at, Time

  def project
    @project ||= Multify::Project.find(id: project_id) if project_id
  end

  def project= project
    @project = project
    project_id = project.id
  end

end

