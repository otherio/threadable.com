class Threadable::Organizations::Create < MethodObject
  attr_reader :organization, :threadable

  def call organizations, attributes
    add_current_user_as_a_member = attributes.key?(:add_current_user_as_a_member) ?
      attributes.delete(:add_current_user_as_a_member) : true

    populate_starter_data = attributes.key?(:populate_starter_data) ?
      attributes.delete(:populate_starter_data) : true

    organization_record = ::Organization.create(attributes)
    @organization = Threadable::Organization.new(organizations.threadable, organization_record)
    @threadable =  @organization.threadable
    return @organization unless organization_record.persisted?

    if threadable.current_user && add_current_user_as_a_member
      @organization.members.add(
        user: organizations.threadable.current_user,
        send_join_notice: false,
        confirmed: true,
      )
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

    starter_data[:conversations].keys.each do |email|
      # enqueue worker jobs here. delay them for the amount of time specified.
      params = starter_data[:conversations][email]

      if params[:delay_hours].present? && params[:delay_hours] > 0
        SendStarterContentWorker.perform_in(params[:delay_hours].hours, threadable.env, email, @organization.id)
      else
        SendStarterContentWorker.perform_async(threadable.env, email, @organization.id)
      end
    end
  end

end
