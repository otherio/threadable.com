require 'spec_helper'

describe Threadable::Organization::Members::Remove, :type => :model do

  delegate :call, to: :described_class

  let(:organization){ double(:organization, id: 134, name: 'lick a baby', members: double(:members, count: 10)) }
  let(:members){ double(:members, organization: organization) }
  let(:scope  ){ double(:scope) }
  let(:billforward) { double(:billforward) }

  before do
    expect(members).to receive(:threadable).and_return(threadable)
    expect(members).to receive(:scope).and_return(scope)

    expect(threadable).to receive(:track).with("Removed User", {
      'Removed User' => 9442,
      'Organization'      => organization.id,
      'Organization Name' => organization.name,
    })

    expect(scope).to receive(:where).with(user_id: 9442).and_return(scope)
    expect(scope).to receive(:delete_all)
  end

  context 'when given a user id' do
    it 'deleted the organization members by the user id' do
      call(members, user_id: 9442)
    end
  end

  context 'when given a user' do
    it 'deleted the organization members by the user id' do
      call(members, user: double(:user, user_id: 9442))
    end
  end

end
