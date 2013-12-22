class PageNavigationWidget < Rails::Widget::Presenter

  option :current_user

  option :current_organization

  option :covered_link_url do
    current_organization.try(:to_param) ? @view.organization_conversations_url(current_organization) : @view.root_url
  end

  option :organizations do
    current_user.organizations.all if current_user
  end

end
