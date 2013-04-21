class TaskMetadataWidget < Rails::Widget::Presenter

  options :task, :user

  def init
    task, user = locals.values_at(:task, :user)
    # @html_options['data-path'] = @view.project_members_path(task.project)
    @html_options['data-doers'] = task.doers.to_json
    @html_options['data-project_members'] = task.project.members.to_json
    @html_options.add_classname 'im-a-doer' if task.doers.include? user
  end

end
