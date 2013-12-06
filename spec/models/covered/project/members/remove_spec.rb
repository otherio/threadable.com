require 'spec_helper'

describe Covered::Project::Members::Remove do

  delegate :call, to: :described_class

  let(:project){ double(:project, id: 134, name: 'lick a baby') }
  let(:members){ double(:members, project: project) }
  let(:scope  ){ double(:scope) }

  before do
    expect(members).to receive(:covered).and_return(covered)
    expect(members).to receive(:scope).and_return(scope)

    expect(covered).to receive(:track).with("Removed User", {
      'Removed User' => 9442,
      'Project'      => project.id,
      'Project Name' => project.name,
    })

    expect(scope).to receive(:where).with(user_id: 9442).and_return(scope)
    expect(scope).to receive(:delete_all)
  end

  context 'when given a user id' do
    it 'deleted the project members by the user id' do
      call(members, user_id: 9442)
    end
  end

  context 'when given a user' do
    it 'deleted the project members by the user id' do
      call(members, user: double(:user, user_id: 9442))
    end
  end

end
