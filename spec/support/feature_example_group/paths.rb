module RSpec::Support::FeatureExampleGroup

  def path_to name
    case name
    when 'the home page'
      root_path
    when 'the sign up page'
      sign_up_path
    when 'the sign in page'
      sign_in_path
    when 'the user setup page'
      setup_users_path params_for_current_path[:token]
    when /^the organization page for "(.+?)"$/
      organization_path Organization.where(name: $1).first!
    when /^the organization conversations page for "(.+?)"$/
      organization_conversations_path Organization.where(name: $1).first!
    # when /^the "(.+?)" task page$/
    #   task = Task.where(subject: $1).first!
    #   organization_task_path task.organization, task

    when /the sign in page prefilled with "(.+?)"/
      sign_in_path(email: $1)

    when /^the "(.+?)" (?:conversation|task) page$/
      conversation = Conversation.where(subject: $1).first!
      organization_conversation_path conversation.organization, conversation
    when /^the "(.+?)" (?:conversation|task) for the "(.+?)" organization$/
      message_name, organization_name = $1, $2
      organization = Organization.where(name: $2).first!
      conversation = organization.conversations.find_by_subject($1)
      organization_conversation_path(organization, conversation)
    else
      raise "\n\nCan't find mapping from \"#{name}\" to a path.\nNow, go and add a mapping in #{__FILE__}\n\n"
    end
  end

  # ok so this is a little weird. In order for us to be able to say asset that we are on "pages"
  # that have content in their URL that the user wouldnt know. Like a token. We can inspect the
  # current path in order to build a path that is equal based on a page name.
  #
  # The example I made this for was 'the user setup page' which is '/users/setup/:token'. In order
  # for the step 'I should be on the user setup page' to be able to complate 'page.current_path' to
  # path_to('the user setup page') we need have a token to use. So if the current url has a token
  # we use that.
  #
  # This feels weird but it's a decent babystep toward something better if we ever need it.
  #
  # Jared
  #
  def params_for_current_path
    app.routes.recognize_path page.current_path
  rescue ActionController::RoutingError
    {}
  end

end
