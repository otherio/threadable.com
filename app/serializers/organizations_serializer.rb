class OrganizationsSerializer < Serializer

  def serialize_record organization
    current_member = organization.members.current_member

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

      email_address_username:       organization.email_address_username,
      email_address:                organization.email_address,
      task_email_address:           organization.task_email_address,
      formatted_email_address:      organization.formatted_email_address,
      formatted_task_email_address: organization.formatted_task_email_address,

      groups: serialize(:groups, organization.groups.all),
      google_user: organization.google_user.present? ? serialize(:users, organization.google_user) : nil,

      can_remove_non_empty_group: !! current_member && current_member.can?(:remove_non_empty_group_from, organization),
      can_set_google_user:        !! current_member && current_member.can?(:set_google_user_for, organization),
    }
  end

end
