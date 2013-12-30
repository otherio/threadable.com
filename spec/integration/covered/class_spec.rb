require 'spec_helper'

describe Covered::Class do

  it "getting records" do
    expect( covered.organizations        .count ).to eq ::Organization       .count
    expect( covered.email_addresses .count ).to eq ::EmailAddress  .count
    expect( covered.users           .count ).to eq ::User          .count
    expect( covered.organizations        .count ).to eq ::Organization       .count
    expect( covered.conversations   .count ).to eq ::Conversation  .count
    expect( covered.tasks           .count ).to eq ::Task          .count
    expect( covered.messages        .count ).to eq ::Message       .count
    expect( covered.attachments     .count ).to eq ::Attachment    .count
    expect( covered.incoming_emails .count ).to eq ::IncomingEmail .count
    expect( covered.events          .count ).to eq ::Event         .count

    expect( covered.organizations        .all.map(&:id) ).to eq ::Organization       .all.map(&:id)
    expect( covered.email_addresses .all.map(&:id) ).to eq ::EmailAddress  .all.map(&:id)
    expect( covered.users           .all.map(&:id) ).to eq ::User          .all.map(&:id)
    expect( covered.organizations        .all.map(&:id) ).to eq ::Organization       .all.map(&:id)
    expect( covered.conversations   .all.map(&:id) ).to eq ::Conversation  .all.map(&:id)
    expect( covered.tasks           .all.map(&:id) ).to eq ::Task          .all.map(&:id)
    expect( covered.messages        .all.map(&:id) ).to eq ::Message       .all.map(&:id)
    expect( covered.attachments     .all.map(&:id) ).to eq ::Attachment    .all.map(&:id)
    expect( covered.incoming_emails .all.map(&:id) ).to eq ::IncomingEmail .all.map(&:id)
    expect( covered.events          .all.map(&:id) ).to eq ::Event         .all.map(&:id)


    events = covered.events.all.group_by(&:class)
    expect( events.keys ).to eq [
      Covered::Events::ConversationCreated,
      Covered::Events::TaskCreated,
      Covered::Events::TaskAddedDoer,
      Covered::Events::TaskDone,
    ]
    expect( events[Covered::Events::ConversationCreated].count ).to eq 12
    expect( events[Covered::Events::TaskCreated        ].count ).to eq 31
    expect( events[Covered::Events::TaskAddedDoer      ].count ).to eq 9
    expect( events[Covered::Events::TaskDone           ].count ).to eq 11

    expect( covered.organizations.all.map{|p| [p.name, p.members.count] } ).to eq [
      ["SF Health Center", 15], ["UCSD Electric Racing", 6]
    ]

    covered.organizations.all.each do |organization|
      expect( organization.members       .count ).to eq ::OrganizationMembership .where(organization_id: organization.id).count
      expect( organization.conversations .count ).to eq ::Conversation      .where(organization_id: organization.id).count
      expect( organization.tasks         .count ).to eq ::Task              .where(organization_id: organization.id).count
      expect( organization.messages      .count ).to eq ::Organization.find(organization.id).messages.count
    end

    expect(covered.env.symbolize_keys).to eq({
      protocol: 'http',
      host: '127.0.0.1',
      port: anything,
      current_user_id: nil,
      worker: false,
    })
  end


end
