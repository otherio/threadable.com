class Covered::CurrentUser::Project < Covered::Project

  autoload :Members
  autoload :Member
  autoload :Conversations
  autoload :Conversation
  autoload :Messages
  autoload :Message
  autoload :Tasks
  autoload :Task

  def initialize current_user, project_record
    @current_user, @project_record = current_user, project_record
  end
  attr_reader :current_user, :project_record
  delegate :covered, to: :current_user

  let(:members){ Members.new(self) }
  let(:conversations){ Conversations.new(self) }
  let(:messages){ Messages.new(self) }
  let(:tasks){ Tasks.new(self) }

  def leave!
    project_record.memberships.where(user_id: current_user.id).first.try(:delete)
  end

end

