class TaskMetadataWidget < Rails::Widget::Presenter

  option :task

  option :user do
    @view.current_user
  end

  def init
    @html_options.add_classname 'im-a-doer' if task.doers.include? user
  end

  html_option('data-doers') {task.doers.all.to_json }
  html_option('data-organization_members') { task.organization.members.all.to_json }

end
