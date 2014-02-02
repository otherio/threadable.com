require_dependency 'threadable/organization'

class Threadable::Organization::Update < MethodObject

  def call organization, attributes
    !!organization.organization_record.update_attributes(attributes)
  end

end
