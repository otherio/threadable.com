module RSpec::Support::Elements

  def selector_for name
    case name
    when 'the navbar'
      '.page_navigation'
    when 'the current user dropdown'
      '.page_navigation .current_user.dropdown .dropdown-toggle'
    when 'the organizations dropdown toggle'
      '.organizations.dropdown .dropdown-toggle'
    when 'the organizations dropdown menu'
      '.organizations.dropdown .dropdown-menu'
    when 'the sign in form'
      'form.sign-in-form'
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
    end
  end

  RSpec.configuration.include self, :type => :request
  RSpec.configuration.include self, :type => :feature

end
