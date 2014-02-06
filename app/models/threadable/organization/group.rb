class Threadable::Organization::Group < Threadable::Group

  def initialize organization, group_record
    @organization, @group_record = organization, group_record
    @threadable = @organization.threadable
  end
  attr_reader :organization, :group_record

  let(:current_member){ members.me }

  #   def gets_no_mail!
  #     organization_membership_record.gets_no_ungrouped_conversation_mail!
  #   end

  #   def gets_messages!
  #     organization_membership_record.gets_ungrouped_conversation_messages!
  #   end

  #   def gets_in_summary!
  #     organization_membership_record.gets_ungrouped_conversations_in_summary!
  #   end

  #   def gets_no_mail?
  #     organization_membership_record.gets_no_ungrouped_conversation_mail?
  #   end

  #   def gets_messages?
  #     organization_membership_record.gets_ungrouped_conversation_messages?
  #   end

  #   def gets_in_summary?
  #     organization_membership_record.gets_ungrouped_conversations_in_summary?
  #   end


  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect} organization_id: #{organization.id.inspect}>)
  end


  #   private

  #   let :group_membership do
  #   end

end
