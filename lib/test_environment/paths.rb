module TestEnvironment::Paths

  def path_to name
    case name
    when 'the home page'
      root_path
    when 'the join page'
      new_user_registration_path
    when /^the project page for "(.+?)"$/
      project_path Project.find_by_name($1)
    when /^the project conversations page for "(.+?)"$/
      project_conversations_path Project.find_by_name($1)
    when /^the "(.+?)" conversation page$/
      task = Task.find_by_subject($1)
      project_conversation_path task.project, task
    else
      raise "\n\nCan't find mapping from \"#{name}\" to a path.\nNow, go and add a mapping in #{__FILE__}\n\n"
    end
  end

end
