class Covered::Operation < MethodObject

  include Let
  include Covered::Dependant::AccessorMethods

  option :covered, required: true

end
