class Api::GroupsSerializer < Serializer

  def serialize_record group
    {
      id:                           group.id,
      param:                        group.to_param,
      slug:                         group.to_param,
      name:                         group.name,
      email_address_tag:            group.email_address_tag,
      color:                        group.color,

      email_address:                group.email_address,
      task_email_address:           group.task_email_address,
      formatted_email_address:      group.formatted_email_address,
      formatted_task_email_address: group.formatted_task_email_address,

      conversations_count:          group.conversations.count,
      organization_slug:            group.organization.slug,

      current_user_is_a_member:     current_user_group_ids.include?(group.id),
    }
  end

  def current_user_group_ids
    @current_user_group_ids ||= current_user.try(:group_ids) || []
  end

end
