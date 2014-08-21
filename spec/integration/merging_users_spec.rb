require 'spec_helper'

describe 'merging users', :type => :request do

  let(:user)                   { threadable.users.find_by_email_address!('bethany@ucsd.example.com') }
  let(:destination_user)       { threadable.users.find_by_email_address!('alice@ucsd.example.com') }
  let(:user_record)            { user.user_record }
  let(:destination_user_record){ destination_user.user_record }

  before do
    @event = Event.create!(
      event_type: 'task_added_doer',
      organization: user_record.organizations.first,
      user_id: user.id,
      content: {doer_id: user.id}
    )
  end

  it 'should copy all the relationships from user to the destination user and delete the user' do
    email_addresses          = user_record.email_addresses.to_set
    organization_memberships = user_record.organization_memberships.map(&:organization_id).to_set
    group_memberships        = user_record.group_memberships.map(&:group_id).to_set
    messages                 = user_record.messages.to_set
    events                   = user_record.events.to_set
    external_authorizations  = user_record.external_authorizations.to_set
    task_doers               = user_record.task_doers.map(&:task_id).to_set

    user.merge_into! destination_user

    expect(User.where(id: user.id)).to_not exist

    destination_user_record.reload

    expect( destination_user_record.email_addresses.to_set                                 ).to be_a_superset email_addresses
    expect( destination_user_record.organization_memberships.map(&:organization_id).to_set ).to be_a_superset organization_memberships
    expect( destination_user_record.group_memberships.map(&:group_id).to_set               ).to be_a_superset group_memberships
    expect( destination_user_record.messages.to_set                                        ).to be_a_superset messages
    expect( destination_user_record.events.to_set                                          ).to be_a_superset events
    expect( destination_user_record.external_authorizations.to_set                         ).to be_a_superset external_authorizations
    expect( destination_user_record.task_doers.map(&:task_id).to_set                       ).to be_a_superset task_doers


    expect( EmailAddress           .where(user_id: user.id) ).to be_empty
    expect( OrganizationMembership .where(user_id: user.id) ).to be_empty
    expect( GroupMembership        .where(user_id: user.id) ).to be_empty
    expect( Message                .where(user_id: user.id) ).to be_empty
    expect( Event                  .where(user_id: user.id) ).to be_empty
    expect( ExternalAuthorization  .where(user_id: user.id) ).to be_empty
    expect( TaskDoer               .where(user_id: user.id) ).to be_empty

    @event.reload
    expect( @event.user_id ).to eq destination_user.id
    expect( @event.content[:doer_id] ).to eq destination_user.id
  end

end
