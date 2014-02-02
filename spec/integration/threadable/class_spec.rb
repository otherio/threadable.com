require 'spec_helper'

describe Threadable::Class do

  it "getting records" do
    expect( threadable.organizations   .count ).to eq ::Organization  .count
    expect( threadable.email_addresses .count ).to eq ::EmailAddress  .count
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
    expect( threadable.users           .all.map(&:id) ).to eq ::User          .all.map(&:id)
    expect( threadable.organizations   .all.map(&:id) ).to eq ::Organization  .all.map(&:id)
    expect( threadable.conversations   .all.map(&:id) ).to eq ::Conversation  .all.map(&:id)
    expect( threadable.tasks           .all.map(&:id) ).to eq ::Task          .all.map(&:id)
    expect( threadable.messages        .all.map(&:id) ).to eq ::Message       .all.map(&:id)
    expect( threadable.attachments     .all.map(&:id) ).to eq ::Attachment    .all.map(&:id)
    expect( threadable.incoming_emails .all.map(&:id) ).to eq ::IncomingEmail .all.map(&:id)
    expect( threadable.events          .all.map(&:id) ).to eq ::Event         .all.map(&:id)


    events = threadable.events.all.group_by(&:class)
    expect( events.keys ).to eq [
      Threadable::Events::ConversationCreated,
      Threadable::Events::TaskCreated,
      Threadable::Events::TaskAddedDoer,
      Threadable::Events::TaskDone,
    ]
    expect( events[Threadable::Events::ConversationCreated].count ).to eq 17
    expect( events[Threadable::Events::TaskCreated        ].count ).to eq 33
    expect( events[Threadable::Events::TaskAddedDoer      ].count ).to eq 11
    expect( events[Threadable::Events::TaskDone           ].count ).to eq 11

    expect( threadable.organizations.all.map{|p| [p.name, p.members.count] } ).to eq [
      ["Other Admins", 4], ["SF Health Center", 15], ["UCSD Electric Racing", 6]
    ]

    threadable.organizations.all.each do |organization|
      expect( organization.members       .count ).to eq ::OrganizationMembership .where(organization_id: organization.id).count
      expect( organization.conversations .count ).to eq ::Conversation           .where(organization_id: organization.id).count
      expect( organization.tasks         .count ).to eq ::Task                   .where(organization_id: organization.id).count
      expect( organization.messages      .count ).to eq ::Organization.find(organization.id).messages.count
    end

    expect(threadable.env.symbolize_keys).to eq({
      protocol: 'http',
      host: '127.0.0.1',
      port: anything,
      current_user_id: nil,
      worker: false,
    })
  end


end