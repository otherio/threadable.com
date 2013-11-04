class Covered::Conversations::Find < Covered::Resource::Action

  option :first, default: false
  option :project_slug
  option :slug

  # covered.conversations.find(project_slug: project_slug, slug: conversation_slug)
  def call
    covered.signed_in!
    scope = covered.current_user.conversations
    scope = scope.joins(:project).where(projects: {slug: project_slug}) if project_slug
    scope = scope.where(slug: slug) if slug
    return scope.first if first
    return scope.to_a
  end

end
