class Projects::Find < Covered::Resource::Action

  option :first, default: false
  option :slug

  # covered.projects.find(slug: 'raceteam', first: true)
  def call
    covered.signed_in!
    scope = covered.current_user.projects
    scope = scope.where(slug: slug) if slug
    return scope.first if first
    return scope.to_a
  end

end
