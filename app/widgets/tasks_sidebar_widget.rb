class TasksSidebarWidget < Rails::Widget::Presenter

  arguments :project

  def initialize view, *arguments, &block
    super
    @html_options[:showing] = 'all_tasks'
  end

end
