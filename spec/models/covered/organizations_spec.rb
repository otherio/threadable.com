require 'spec_helper'

describe Covered::Organizations do

  subject{ covered.organizations }

  %w{
    Create
  }.each do |constant|
    describe "::#{constant}" do
      specify{ "#{described_class}::#{constant}".constantize.name.should == "#{described_class}::#{constant}" }
    end
  end

  describe 'new' do
    it 'returns a Covered::Organization' do
      expect(subject.new.class).to eq Covered::Organization
    end
  end

  describe '#create' do
    it 'should attempt to create a organization and return a Covered::Organization' do
      organization = subject.create(name: 'pet a kitten')
      expect(organization.class).to eq Covered::Organization
      expect(organization.organization_record).to be_a ::Organization
    end
  end

  describe '#find_by_email_address' do
    let!(:organization) { FactoryGirl.create(:organization, name: 'foo') }

    it 'finds the organization' do
      organization_record = subject.find_by_email_address('foo@covered.io')
      expect(organization_record.id).to eq organization.id
    end

    it 'finds the organization if there are labels/commands' do
      organization_record = subject.find_by_email_address('foo+task@covered.io')
      expect(organization_record.id).to eq organization.id
    end

    it 'strips non ascii characters before searching' do
      organization_record = subject.find_by_email_address('★foo★@covered.io')
      expect(organization_record.id).to eq organization.id
    end
  end

end
