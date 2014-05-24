class GroupsSerializer < Serializer

  def serialize_record group
    {
      id:                           group.id,
      slug:                         group.slug,
      name:                         group.name,
      description:                  group.description,
      email_address_tag:            group.email_address_tag,
      subject_tag:                  group.subject_tag,
      color:                        group.color,
      auto_join:                    group.auto_join?,
      hold_messages:                group.hold_messages?,
      alias_email_address:          group.alias_email_address,
      webhook_url:                  group.webhook_url,
      google_sync:                  group.google_sync,

      email_address:                group.email_address,
      task_email_address:           group.task_email_address,
      formatted_email_address:      group.formatted_email_address,
      formatted_task_email_address: group.formatted_task_email_address,
      internal_email_address:       group.internal_email_address,
      internal_task_email_address:  group.internal_task_email_address,

      conversations_count:          group.conversations.count,
      members_count:                group.members.count,
      organization_slug:            group.organization.slug,

      current_user_is_a_member:     current_user_group_ids.include?(group.id),
    }
  end

  def current_user_group_ids
    @current_user_group_ids ||= current_user.try(:group_ids) || []
  end

end
