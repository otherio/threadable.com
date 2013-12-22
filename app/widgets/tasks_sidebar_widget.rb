class TasksSidebarWidget < Rails::Widget::Presenter

  arguments :organization

  option :with_title, false

  option :conversations do
    organization.conversations.all # includes(:organization)
  end

  option :tasks do
    organization.tasks.all
  end

  option :my_tasks do
    organization.tasks.all_for_user @view.current_user
  end

  option :done_tasks do
    tasks.select(&:done?)
  end

  option :not_done_tasks do
    tasks.reject(&:done?)
  end

  option :my_done_tasks do
    my_tasks.select(&:done?)
  end

  option :my_not_done_tasks do
    my_tasks.reject(&:done?)
  end

  def init
    @html_options['data-conversations'] = conversations.present?
    @html_options['data-with_title'] = with_title
  end

end
