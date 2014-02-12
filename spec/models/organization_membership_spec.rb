require 'spec_helper'

describe OrganizationMembership do
  it { should belong_to :user }
  it { should belong_to :organization }

  subject{ OrganizationMembership.new attributes }

  def attributes
    {

    }
  end

  its(:ungrouped_mail_delivery){ should eq :each_message }

  describe '#ungrouped_mail_delivery' do
    it 'takes an expected value and stores it as an integer' do
      expect(subject.ungrouped_mail_delivery).to eq :each_message
      expect(subject.attributes['ungrouped_mail_delivery']).to eq 1

      subject.ungrouped_mail_delivery = :no_mail
      expect(subject.attributes['ungrouped_mail_delivery']).to eq 0
      expect(subject.ungrouped_mail_delivery).to eq :no_mail

      subject.ungrouped_mail_delivery = :in_summary
      expect(subject.attributes['ungrouped_mail_delivery']).to eq 2
      expect(subject.ungrouped_mail_delivery).to eq :in_summary

      expect{ subject.ungrouped_mail_delivery = :asddsad }.to raise_error ArgumentError
    end
  end

end
