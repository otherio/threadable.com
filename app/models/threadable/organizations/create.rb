class Threadable::Organizations::Create < MethodObject
  attr_reader :organization

  def call organizations, attributes
    add_current_user_as_a_member = attributes.key?(:add_current_user_as_a_member) ?
      attributes.delete(:add_current_user_as_a_member) : true

    populate_starter_data = attributes.key?(:populate_starter_data) ?
      attributes.delete(:populate_starter_data) : true

    organization_record = ::Organization.create(attributes)
    @organization = Threadable::Organization.new(organizations.threadable, organization_record)
    return @organization unless organization_record.persisted?

    if organizations.threadable.current_user && add_current_user_as_a_member
      @organization.members.add(user: organizations.threadable.current_user, send_join_notice: false)
    end

    populate_starter_data! if populate_starter_data
    return @organization
  end

  def populate_starter_data!
    return if ENV['NO_STARTER_DATA'] == 'true'
    starter_data = HashWithIndifferentAccess.new(YAML.load(Rails.root.join("config/starter_data.yml").read))

    starter_data[:groups].each do |group_params|
      organization.groups.create(group_params)
    end

    starter_data[:conversations].each do |conversation_params|
      container = organization
      if conversation_params[:group]
        groups = [organization.groups.find_by_slug!(conversation_params[:group])]
      end

      conversation = container.conversations.create(
        subject: conversation_params[:subject],
        task: conversation_params[:task],
        groups: groups
      )

      conversation.messages.create(
        subject: conversation_params[:subject],
        from: conversation_params[:from],
        body_plain: conversation_params[:body_plain],
        body_html: conversation_params[:body_html],
        to_header: conversation_params[:to_header],
      )
    end
  end

end
