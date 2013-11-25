class Projects::Create < Covered::Resource::Action

  option :attributes, required: true

  # covered.projects.find(slug: 'raceteam', first: true)
  def call
    covered.signed_in!
    Project.create(attributes)
  end

end
