class SendStarterContentWorker < Threadable::ScheduledWorker
  def perform! email, organization_id
    @email = email
    @organization = threadable.organizations.find_by_id(organization_id)

    starter_data = HashWithIndifferentAccess.new(YAML.load(Rails.root.join("config/starter_data.yml").read))
    @params = starter_data[:conversations][email]

    @conversation = find_or_create_conversation!
    create_message!
  end

  attr_reader :email, :params, :organization, :conversation

  private

  def create_message!
    conversation.messages.create(
      subject:    params[:subject],
      from:       params[:from],
      body_plain: text(binding),
      body_html:  html(binding),
      to_header:  organization.formatted_email_address,
    )
  end

  def find_or_create_conversation!
    if params[:parent_slug].present?
      organization.conversations.find_by_slug!(params[:parent_slug])
    else
      if params[:group]
        groups = [organization.groups.find_by_slug!(params[:group])]
      end

      organization.conversations.create(
        subject: params[:subject],
        task: params[:task],
        groups: groups
      )
    end
  end

  def html(source_binding)
    template = Rails.root.join("#{basename}.html.haml").read
    Haml::Engine.new(template).render(source_binding)
  end

  def text(source_binding)
    template = Rails.root.join("#{basename}.text.erb").read
    ERB.new(template).result(source_binding)
  end

  def basename
    "app/views/starter_content/#{email}"
  end
end
