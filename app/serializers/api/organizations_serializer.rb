class Api::OrganizationsSerializer < Serializer

  def initialize groups, current_user_group_ids=[]
    super(groups)
    @current_user_group_ids = current_user_group_ids
  end

  def serialize_record organization
    json = {
      id:          organization.id,
      param:       organization.to_param,
      name:        organization.name,
      short_name:  organization.short_name,
      slug:        organization.slug,
      subject_tag: organization.subject_tag,
      description: organization.description,

      email_address:                organization.email_address,
      task_email_address:           organization.task_email_address,
      formatted_email_address:      organization.formatted_email_address,
      formatted_task_email_address: organization.formatted_task_email_address,
    }

    json.merge! Api::GroupsSerializer[organization.groups.all, @current_user_group_ids]

    json
  end

end
