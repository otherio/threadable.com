class Threadable::Group::Member < Threadable::User

  def initialize group, group_membership_record
    @group, @group_membership_record = group, group_membership_record
    @threadable = group.threadable
    group.id == group_membership_record.group_id or raise ArgumentError
  end
  attr_reader :group, :group_membership_record
  delegate :group_id, :user_id, to: :group_membership_record

  def user_record
    group_membership_record.user
  end

  def organization_record
    group_membership_record.organization
  end


  def delivery_method
    group_membership_record.delivery_method
  end

  def delivery_method= delivery_method
    group_membership_record.update_attribute(:delivery_method, delivery_method)
  end

  Threadable::DELIVERY_METHODS.each do |delivery_method|
    define_method "gets_#{delivery_method}?" do
      self.delivery_method == delivery_method
    end
    define_method "gets_#{delivery_method}!" do
      self.delivery_method = delivery_method
    end
  end

  # def gets_no_mail!
  #   group_membership_record.gets_no_mail!
  # end

  # def gets_messages!
  #   group_membership_record.gets_messages!
  # end

  # def gets_in_summary!
  #   group_membership_record.gets_in_summary!
  # end

  # def gets_no_mail?
  #   group_membership_record.gets_no_mail?
  # end

  # def gets_messages?
  #   group_membership_record.gets_messages?
  # end

  # def gets_in_summary?
  #   group_membership_record.gets_in_summary?
  # end


  def inspect
    %(#<#{self.class} group_id: #{group_id.inspect}, user_id: #{user_id.inspect}, email_address: #{email_address.to_s.inspect}, slug: #{slug.inspect}>)
  end


end
