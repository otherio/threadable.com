module RSpec::Support::Elements

  def selector_for name
    case name
    when 'the sign in form'
      '.sign-in-form'
    when 'the navbar'
      '.navbar'
    when 'the groups pane'
      '.groups-pane'
    when 'the conversations pane'
      '.conversations-pane'
    when 'the conversation pane'
      '.conversation-pane'
    when 'the compose button'
      '.navbar .uk-icon-edit'
    when 'the mark as done button'
      '.task-controls .uk-icon-check'
    when 'the mark not done button'
      '.task-controls .uk-icon-check-square'
    when 'the change doers button'
      '.doers a.label'
    # when 'the current user dropdown'
    #   '.page_navigation .current_user.dropdown .dropdown-toggle'
    # when 'the organizations dropdown toggle'
    #   '.organizations.dropdown .dropdown-toggle'
    # when 'the organizations dropdown menu'
    #   '.organizations.dropdown .dropdown-menu'
    # when 'the modal'
    #   '.modal'
    # when 'the tasks sidebar'
    #   '.tasks_sidebar'
    # when 'the done tasks list'
    #   '.tasks_sidebar .done .task_list'
    # when 'the not done tasks list'
    #   '.tasks_sidebar .not_done .task_list'
    # when 'the list of doers for this task'
    #   '.task_metadata .doers'
    else
      raise ArgumentError, "no selector for: #{name.inspect}"
    end
  end

  RSpec.configuration.include self, :type => :request
  RSpec.configuration.include self, :type => :feature

end
