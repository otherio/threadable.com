require 'spec_helper'

describe Threadable::Organizations, :type => :model do

  subject{ threadable.organizations }

  %w{
    Create
  }.each do |constant|
    describe "::#{constant}" do
      specify{ expect("#{described_class}::#{constant}".constantize.name).to eq("#{described_class}::#{constant}") }
    end
  end

  describe 'new' do
    it 'returns a Threadable::Organization' do
      expect(subject.new.class).to eq Threadable::Organization
    end
  end

  describe '#create' do
    it 'should attempt to create a organization and return a Threadable::Organization' do
      organization = subject.create(name: 'pet a kitten')
      expect(organization.class).to eq Threadable::Organization
      expect(organization.organization_record).to be_a ::Organization
    end
  end

  describe '#find_by_email_address' do
    let!(:organization) { FactoryGirl.create(:organization, name: 'foo') }

    it 'finds the organization' do
      organization_record = subject.find_by_email_address('foo@localhost')
      expect(organization_record.id).to eq organization.id
    end

    it 'finds the organization by subdomain' do
      organization_record = subject.find_by_email_address('groupy@foo.localhost')
      expect(organization_record.id).to eq organization.id
    end

    it 'finds the organization if there are labels/commands' do
      organization_record = subject.find_by_email_address('foo+task@localhost')
      expect(organization_record.id).to eq organization.id
    end

    it 'strips non ascii characters before searching' do
      organization_record = subject.find_by_email_address('★foo★@localhost')
      expect(organization_record.id).to eq organization.id
    end

    context 'when the org name contains a dot' do
      let!(:organization) { FactoryGirl.create(:organization, name: 'foo-bar') }

      it 'converts the dot to a dash and finds the organization' do
        organization_record = subject.find_by_email_address('foo.bar@localhost')
        expect(organization_record.id).to eq organization.id
      end
    end
  end

end
