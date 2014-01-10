class Api::OrganizationsSerializer < Serializer

  def serialize_record organization
    {
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

      links: {
        members:       api_organization_members_path(organization),
        groups:        api_organization_groups_path(organization),
        conversations: api_organization_conversations_path(organization),
        tasks:         api_organization_tasks_path(organization),
      }
    }
  end

end
