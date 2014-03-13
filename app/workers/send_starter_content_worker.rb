class SendStarterContentWorker < Threadable::Worker

  def perform! email, organization_id
    @email = email
    @organization = threadable.organizations.find_by_id(organization_id)

    starter_data = HashWithIndifferentAccess.new(YAML.load(Rails.root.join("config/starter_data.yml").read))
    @params = starter_data[:conversations][email]

    return unless @params

    @conversation = find_or_create_conversation!
    create_message!
  end

  attr_reader :email, :params, :organization, :conversation

  private

  def create_message!
    conversation.messages.create(
      subject:    params[:subject],
      from:       params[:from],
      body_plain: text,
      body_html:  html,
      to_header:  organization.formatted_email_address,
    )
  end

  def find_or_create_conversation!
    conversation = organization.conversations.find_by_subject(params[:subject])
    return conversation if conversation.present?

    if params[:group]
      groups = [organization.groups.find_by_slug!(params[:group])]
    end

    organization.conversations.create(
      subject: params[:subject],
      task: params[:task],
      groups: groups
    )
  end

  def html
    template = Rails.root.join("#{basename}.html.haml").read
    Haml::Engine.new(template).render(binding)
  end

  def text
    template = Rails.root.join("#{basename}.text.erb").read
    ERB.new(template).result(binding)
  end

  def basename
    "app/views/starter_content/#{email}"
  end
end
