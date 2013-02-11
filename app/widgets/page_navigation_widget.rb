class PageNavigationWidget < Rails::Widget::Presenter

  options :user, :project

  local :multify_link_url do
    project.try(:persisted?) ? @view.project_conversations_url(project) : @view.root_url
  end

  private

  def project
    locals[:project]
  end

end
