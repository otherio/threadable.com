class Covered::Groups::Create < MethodObject

  def call groups, attributes
    group_record = ::Group.create(attributes)
    group = Covered::Group.new(groups.covered, group_record)
    return group
  end

end
