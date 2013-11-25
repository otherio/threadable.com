class Covered::Projects::Create < MethodObject

  def call covered, attributes
    ::Project.create(attributes)
  end

end
