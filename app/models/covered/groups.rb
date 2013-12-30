class Covered::Groups < Covered::Collection

  def all
    scope.reload.map{ |group| group_for group }
  end

  def create attributes={}
    Create.call(self, attributes)
  end

  def create! attributes={}
    group = create(attributes)
    group.persisted? or raise Covered::RecordInvalid, "Group invalid: #{group.errors.full_messages.to_sentence}"
    group
  end

  private

  def scope
    ::Group.all
  end

  def group_for group_record
    Covered::Group.new(covered, group_record) if group_record
  end

end
