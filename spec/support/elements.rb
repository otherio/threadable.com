module RSpec::Support::Elements

  def selector_for name
    case name
    when 'the sign in form'
      '.sign-in-form'
    when 'the topbar'
      '.topbar'
    when 'the sidebar'
      '.sidebar'
    when 'my groups'
      '.my-groups'
    when 'other groups'
      '.other-groups'
    when 'the conversations pane'
      '.pane1'
    when 'the conversation pane'
      '.pane2'
    when 'the compose button'
      '.topbar .uk-icon-edit'
    when 'the mark as done button'
      '.task-controls .uk-icon-check'
    when 'the mark not done button'
      '.task-controls .uk-icon-check-square'
    when 'the change doers button'
      '.doers a.label'
    when 'the change groups button'
      '.conversation-groups a.plus-button'
    else
      raise ArgumentError, "no selector for: #{name.inspect}"
    end
  end

  RSpec.configuration.include self, :type => :request
  RSpec.configuration.include self, :type => :feature

end
