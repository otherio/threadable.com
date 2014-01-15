module SerializerConcern

  def serializer type=nil
    "#{type.to_s.camelize}Serializer".constantize
  end

  # serialize User.all
  # serialize User.first
  # serialize :users, User.all
  # serialize :users, User.first
  def serialize type, payload, options={}
    serializer(type).serialize(covered, payload, options)
  end

end
