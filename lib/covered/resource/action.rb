class Covered::Resource::Action < MethodObject

  include Let

  option :resource, required: true

  delegate :covered, to: :resource

end
