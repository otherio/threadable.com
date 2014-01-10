class Api::TasksSerializer < Serializer

  def serialize_record task
    {
      id:                 task.id,
      param:              task.to_param,
      slug:               task.slug,
      subject:            task.subject,
      position:           task.position,
      done:               task.done?,

      created_at:         task.created_at,
      updated_at:         task.updated_at,

      links: {
        conversations: api_organization_conversation_path(task.organization, task),
        messages:      api_organization_conversation_messages_path(task.organization, task),
        doers:         api_organization_task_doers_path(task.organization, task),
      },
    }
  end

end
