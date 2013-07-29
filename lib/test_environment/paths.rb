module TestEnvironment::Paths

  def path_to name
    case name
    when 'the home page'
      root_path
    when 'the join page'
      new_user_registration_path
    when 'the sign in page'
      new_user_session_path
    when /^the project page for "(.+?)"$/
      project_path Project.where(name: $1)
    when /^the project conversations page for "(.+?)"$/
      project_conversations_path Project.where(name: $1).first!
    # when /^the "(.+?)" task page$/
    #   task = Task.where(subject: $1).first!
    #   project_task_path task.project, task
    when /^the "(.+?)" (?:conversation|task) page$/
      conversation = Conversation.where(subject: $1).first!
      project_conversation_path conversation.project, conversation
    when /^the "(.+?)" (?:conversation|task) for the "(.+?)" project$/
      message_name, project_name = $1, $2
      project = Project.where(name: $2).first!
      conversation = project.conversations.find_by_subject($1)
      project_conversation_path(project, conversation)
    else
      raise "\n\nCan't find mapping from \"#{name}\" to a path.\nNow, go and add a mapping in #{__FILE__}\n\n"
    end
  end

end
