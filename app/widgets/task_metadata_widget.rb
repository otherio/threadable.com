class TaskMetadataWidget < Rails::Widget::Presenter

  option :task

  option :user

  def init
    @html_options.add_classname 'im-a-doer' if task.doers.include? user
  end

  html_option('data-doers') { task.doers.to_json }
  html_option('data-project_members') { task.project.members.to_json }

end
