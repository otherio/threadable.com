class Threadable::Organization::Group < Threadable::Group

  def initialize organization, group_record
    @organization, @group_record = organization, group_record
    @threadable = @organization.threadable
  end
  attr_reader :organization, :group_record


  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect} organization_id: #{organization.id.inspect}>)
  end

end
