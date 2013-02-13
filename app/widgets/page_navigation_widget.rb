class PageNavigationWidget < Rails::Widget::Presenter

  options :current_user, :current_project

  local :multify_link_url do
    current_project ? @view.project_conversations_url(current_project) : @view.root_url
  end

  local :projects do
    current_user.projects if current_user
  end

  private

  def current_user
    locals[:current_user]
  end

  def current_project
    locals[:current_project]
  end

end
