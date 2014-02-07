require 'spec_helper'

describe OrganizationMembership do

  it { should belong_to :user }
  it { should belong_to :organization }
  it { should have_many :email_addresses }
  it { should validate_presence_of :organization_id }
  it { should validate_presence_of :user_id }

  let(:organization_id)          { 1 }
  let(:user_id)                  { 1 }
  let(:gets_email)               { true }
  let(:ungrouped_delivery_method){ :each_message }

  def attributes
    {
      organization_id:           organization_id,
      user_id:                   user_id,
      gets_email:                gets_email,
      ungrouped_delivery_method: ungrouped_delivery_method,
    }
  end

  subject{ OrganizationMembership.create!(attributes) }

  its(:ungrouped_delivery_method){ should eq :each_message }

  describe '#ungrouped_delivery_method=' do
    OrganizationMembership::DELIVERY_METHODS.each_with_index do |delivery_method, index|
      context "when given #{delivery_method.inspect}" do
        it "sets the attribute value to #{index}" do
          subject.ungrouped_delivery_method = delivery_method
          expect(subject.ungrouped_delivery_method).to eq delivery_method
          expect(subject.attributes['ungrouped_delivery_method']).to eq index
        end
      end
    end
  end

end
