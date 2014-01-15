class Covered::Organization::Group < Covered::Group

  def initialize organization, group_record
    @organization, @group_record = organization, group_record
    @covered = @organization.covered
  end
  attr_reader :organization, :group_record


  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect} organization_id: #{organization.id.inspect}>)
  end

end
