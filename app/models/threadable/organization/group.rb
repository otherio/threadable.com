class Threadable::Organization::Group < Threadable::Group

  def initialize organization, group_record
    @organization, @group_record = organization, group_record
    @threadable = @organization.threadable
  end
  attr_reader :organization, :group_record

  let(:current_member){ members.me }

  def delivery_method
    organization_membership_record.ungrouped_delivery_method
  end

  def delivery_method= delivery_method
    organization_membership_record.update_attribute(:ungrouped_delivery_method, delivery_method)
  end

  Threadable::DELIVERY_METHODS.each do |delivery_method|
    define_method "gets_#{delivery_method}?" do
      self.delivery_method == delivery_method
    end
    define_method "gets_#{delivery_method}!" do
      self.delivery_method = delivery_method
    end
  end

  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect} organization_id: #{organization.id.inspect}>)
  end


  #   private

  #   let :group_membership do
  #   end

end
