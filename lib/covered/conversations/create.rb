class Covered::Conversations::Create < Covered::Resource::Action

  option :subject,      required: true
  option :body,         required: true
  option :project_slug, required: true
  option :attachments

  let(:project){ covered.projects.get(slug: project_slug) }

  def call
    covered.signed_in!
    Covered::Conversation.transaction do
      create_conversation!
      create_first_message!
      @conversation
    end
  end

  def create_conversation!
    @conversation = project.conversations.create!(
      creator: covered.current_user,
      subject: subject,
    )
  end

  def create_first_message!
    @conversation_message = covered.messages.create(
      project_slug: project_slug,
      conversation_slug: @conversation.slug,
      message_attributes: { body: body, attachments: attachments },
    )
    raise ActiveRecord::Rollback unless @conversation_message.persisted?
  end


end
