class TasksSidebarWidget < Rails::Widget::Presenter

  arguments :project

  option :with_title, false

  option :conversations do
    project.conversations.all # includes(:project)
  end

  option :tasks do
    project.tasks.all
  end

  option :my_tasks do
    tasks.select do |task|
      task.doers.include? @view.current_user
    end
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
