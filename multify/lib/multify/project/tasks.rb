class Multify::Project::Tasks < Multify::Resource::HasMany

  def initialize project_id
    super(Multify::Task, project_id: project_id)
  end

end
