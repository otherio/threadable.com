module CapybaraEnvironment::Elements

  def selector_for name
    case name
    when 'the navbar'
      '.page_navigation'
    when 'the projects dropdown toggle'
      '.projects.dropdown .dropdown-toggle'
    when 'the projects dropdown menu'
      '.projects.dropdown .dropdown-menu'
    when 'the sign in form'
      '.sign_in_form .sign-in-form form'
    when 'the modal'
      '.modal'
    when 'the tasks sidebar'
      '.tasks_sidebar'
    when 'the done tasks list'
      '.tasks_sidebar .done .task_list'
    when 'the not done tasks list'
      '.tasks_sidebar .not_done .task_list'
    when 'the list of doers for this task'
      '.task_metadata .doers'
    when 'the first message'
      all('.message').first
    end
  end

  def within_element name, &block
    within(selector_for(name), &block)
  end

end
