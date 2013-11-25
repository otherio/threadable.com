require 'spec_helper'

describe Covered::CurrentUser::Projects do

  before{ covered.current_user_id = create(:user).id }

  subject{ covered.current_user.projects }

  %w{
    Create
  }.each do |constant|
    describe "::#{constant}" do
      specify{ "#{described_class}::#{constant}".constantize.name.should == "#{described_class}::#{constant}" }
    end
  end

  describe 'new' do
    it 'returns a Covered::Project' do
      expect(subject.new.class).to eq Covered::CurrentUser::Project
    end
  end

  describe 'create' do
    it 'should attempt to create a project and return a Covered::Project' do
      project = subject.create(name: 'pet a kitten')
      expect(project.class).to eq Covered::CurrentUser::Project
      expect(project.project_record).to be_a ::Project
    end
  end

end