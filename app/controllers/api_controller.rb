class ApiController < ApplicationController

  private

  def serializer type=nil
    type ||= self.class.name[%r{\AApi::(.+)Controller\Z},1]
    "Api::#{type.to_s.camelize}Serializer".constantize
  end

  # serialize User.all
  # serialize User.first
  # serialize :users, User.all
  # serialize :users, User.first
  def serialize type=nil, payload
    serializer(type).serialize(covered, payload)
  end

end
