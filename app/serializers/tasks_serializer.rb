class TasksSerializer < Serializer

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
    }
  end

end
