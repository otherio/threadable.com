class OrganizationsSerializer < Serializer

  def serialize_record organization
    @current_member = organization.members.current_member

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
      plan:              organization.plan,
      public_signup:     organization.public_signup?,

      email_address_username:       organization.email_address_username,
      email_address:                organization.email_address,
      task_email_address:           organization.task_email_address,
      formatted_email_address:      organization.formatted_email_address,
      formatted_task_email_address: organization.formatted_task_email_address,

      groups:        serialize(:groups, organization.groups.all),
      email_domains: serialize(:email_domains, organization.email_domains.all),
      google_user:   organization.google_user.present? ? serialize(:users, organization.google_user) : nil,

      can_remove_non_empty_group: can?(:remove_non_empty_group_from, organization),
      can_be_google_user:         can?(:be_google_user_for, organization),
      can_change_settings:        can?(:change_settings_for, organization),
      can_invite_members:         can?(:create, organization.members),

      organization_membership_permission: organization.settings.organization_membership_permission,
      group_membership_permission: organization.settings.group_membership_permission,
      group_settings_permission:   organization.settings.group_settings_permission,
    }
  end

end
