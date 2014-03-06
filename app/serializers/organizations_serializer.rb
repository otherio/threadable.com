class OrganizationsSerializer < Serializer

  def serialize_record organization
    {
      id:                organization.id,
      param:             organization.to_param,
      name:              organization.name,
      short_name:        organization.short_name,
      slug:              organization.slug,
      subject_tag:       organization.subject_tag,
      description:       organization.description,
      has_held_messages: organization.held_messages.count > 0,
      trusted:           organization.trusted?,

      email_address:                organization.email_address,
      task_email_address:           organization.task_email_address,
      formatted_email_address:      organization.formatted_email_address,
      formatted_task_email_address: organization.formatted_task_email_address,

      groups: serialize(:groups, organization.groups.all),
    }
  end

end
