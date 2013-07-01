class PageNavigationWidget < Rails::Widget::Presenter

  option :current_user

  option :current_project

  option :covered_link_url do
    current_project ? @view.project_conversations_url(current_project) : @view.root_url
  end

  option :projects do
    current_user.projects if current_user
  end

end
