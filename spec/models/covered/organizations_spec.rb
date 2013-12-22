require 'spec_helper'

describe Covered::Organizations do

  subject{ covered.projects }

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
    it 'should attempt to create a project and return a Covered::Organization' do
      project = subject.create(name: 'pet a kitten')
      expect(project.class).to eq Covered::Organization
      expect(project.project_record).to be_a ::Organization
    end
  end

  describe '#find_by_email_address' do
    let!(:project) { FactoryGirl.create(:project, name: 'foo') }

    it 'finds the project' do
      project_record = subject.find_by_email_address('foo@covered.io')
      expect(project_record.id).to eq project.id
    end

    it 'finds the project if there are labels/commands' do
      project_record = subject.find_by_email_address('foo+task@covered.io')
      expect(project_record.id).to eq project.id
    end

    it 'strips non ascii characters before searching' do
      project_record = subject.find_by_email_address('★foo★@covered.io')
      expect(project_record.id).to eq project.id
    end
  end

end
