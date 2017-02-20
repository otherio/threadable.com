require 'spec_helper'

describe Threadable::Class, :type => :request do

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  it "getting records" do
    expect( threadable.organizations   .count ).to eq ::Organization  .count
    expect( threadable.email_addresses .count ).to eq ::EmailAddress  .count
    expect( threadable.email_domains   .count ).to eq ::EmailDomain   .count
    expect( threadable.users           .count ).to eq ::User          .count
    expect( threadable.organizations   .count ).to eq ::Organization  .count
    expect( threadable.conversations   .count ).to eq ::Conversation  .count
    expect( threadable.tasks           .count ).to eq ::Task          .count
    expect( threadable.messages        .count ).to eq ::Message       .count
    expect( threadable.attachments     .count ).to eq ::Attachment    .count
    expect( threadable.incoming_emails .count ).to eq ::IncomingEmail .count
    expect( threadable.events          .count ).to eq ::Event         .count

    expect( threadable.organizations   .all.map(&:id) ).to eq ::Organization  .all.map(&:id)
    expect( threadable.email_addresses .all.map(&:id) ).to eq ::EmailAddress  .all.map(&:id)
    expect( threadable.email_domains   .all.map(&:id) ).to eq ::EmailDomain   .all.map(&:id)
    expect( threadable.users           .all.map(&:id) ).to eq ::User          .all.map(&:id)
    expect( threadable.organizations   .all.map(&:id) ).to eq ::Organization  .all.map(&:id)
    expect( threadable.conversations   .all.map(&:id) ).to eq ::Conversation  .all.map(&:id)
    expect( threadable.tasks           .all.map(&:id) ).to eq ::Task          .all.map(&:id)
    expect( threadable.messages        .all.map(&:id) ).to eq ::Message       .all.map(&:id)
    expect( threadable.attachments     .all.map(&:id) ).to eq ::Attachment    .all.map(&:id)
    expect( threadable.incoming_emails .all.map(&:id) ).to eq ::IncomingEmail .all.map(&:id)
    expect( threadable.events          .all.map(&:id) ).to eq ::Event         .all.map(&:id)


    events = threadable.events.all.group_by(&:class)
    expect( events.keys.to_set ).to eq Set[
      Threadable::Events::ConversationCreated,
      Threadable::Events::ConversationTrashed,
      Threadable::Events::TaskCreated,
      Threadable::Events::TaskAddedDoer,
      Threadable::Events::ConversationAddedGroup,
      Threadable::Events::TaskDone,
      Threadable::Events::ConversationRemovedGroup,
    ]
    expect( events[Threadable::Events::ConversationCreated].count ).to eq 20
    expect( events[Threadable::Events::ConversationTrashed].count ).to eq 1
    expect( events[Threadable::Events::TaskCreated        ].count ).to eq 34
    expect( events[Threadable::Events::TaskAddedDoer      ].count ).to eq 11
    expect( events[Threadable::Events::TaskDone           ].count ).to eq 11

    expect( threadable.organizations.all.map{|p| [p.name, p.members.count] } ).to eq [
      ["Other Admins", 2], ["SF Health Center", 16], ["UCSD Electric Racing", 10]
    ]

    threadable.organizations.all.each do |organization|
      expect( organization.members       .count ).to eq ::OrganizationMembership .where(organization_id: organization.id, active: true).count
      expect( organization.conversations .count ).to eq ::Conversation           .where(organization_id: organization.id).count
      expect( organization.tasks         .count ).to eq ::Task                   .where(organization_id: organization.id).count
      expect( organization.messages      .count ).to eq ::Organization.find(organization.id).messages.count
    end

    expect(threadable.env.symbolize_keys).to match({
      protocol: 'http',
      host: '127.0.0.1',
      port: anything,
      current_user_id: anything,
      worker: false,
    })
  end

  describe '#refresh' do
    it 'removes the defined instance variables' do
      threadable.email_addresses
      threadable.refresh
      expect(threadable.instance_variable_get(:@email_addresses)).to be_nil
    end
  end


end
