module FindHelpers

  def find_user slug
    Covered::User.where(slug: slug).first!
  end

  def find_project slug
    Covered::Project.where(slug: slug).first!
  end

  def find_conversation project_slug, conversation_slug
    Covered::Conversation.joins(:project).where(
      projects: {slug: project_slug},
      slug: conversation_slug,
    ).first!
  end

end
