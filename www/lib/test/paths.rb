module Test::Paths

  include Rails.application.routes.url_helpers

  def page_name_to_path name

    case name.to_s
    when /^the home ?page$/
      root_path
    when /^the task page for the "([^"]+)" task of the "([^"]+)" project$/
      # task_name, project_name = $1, $2
      # project = Multify::Project.find(name: project_name).first
      # task    = project.tasks.find(name: task_name).first
      project_task_path($2, $1)
    when /^the project page for "([^"]+)"$/
      project_path($1)
    when /^the join page$/
      new_user_path
    when /^the users page for "([^"]+)"$/
      user_path($1)
    else
      raise "I dont know how to go to #{name.inspect}"
    end

  end

end
