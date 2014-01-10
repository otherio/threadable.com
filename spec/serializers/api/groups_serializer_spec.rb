require 'spec_helper'

describe Api::GroupsSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:electronics) { raceteam.groups.find_by_email_address_tag!('electronics') }
  let(:fundraising) { raceteam.groups.find_by_email_address_tag!('fundraising') }

  context 'when given a single record' do
    subject{ described_class[electronics] }
    it do
      should eq(
        group: {
          id:          electronics.id,
          param:       "electronics",
          slug:        "electronics",
          name:        "Electronics",
          email_address_tag: "electronics",
          color:       "#aaaaaa",

          email_address:                electronics.email_address,
          task_email_address:           electronics.task_email_address,
          formatted_email_address:      electronics.formatted_email_address,
          formatted_task_email_address: electronics.formatted_task_email_address,

          links: {
            members:       "/api/organizations/#{raceteam.to_param}/groups/#{electronics.to_param}/members",
            conversations: "/api/organizations/#{raceteam.to_param}/groups/#{electronics.to_param}/conversations",
            tasks:         "/api/organizations/#{raceteam.to_param}/groups/#{electronics.to_param}/tasks",
          },
        }
      )
    end
  end

  context 'when given a collection of records' do
    subject{ described_class[[electronics, fundraising]] }
    it do
      should eq(
        groups: [
          {
            id:          electronics.id,
            param:       "electronics",
            slug:        "electronics",
            name:        "Electronics",
            email_address_tag: "electronics",
            color:       "#aaaaaa",

            email_address:                electronics.email_address,
            task_email_address:           electronics.task_email_address,
            formatted_email_address:      electronics.formatted_email_address,
            formatted_task_email_address: electronics.formatted_task_email_address,

            links: {
              members:       "/api/organizations/#{raceteam.to_param}/groups/#{electronics.to_param}/members",
              conversations: "/api/organizations/#{raceteam.to_param}/groups/#{electronics.to_param}/conversations",
              tasks:         "/api/organizations/#{raceteam.to_param}/groups/#{electronics.to_param}/tasks",
            },
          },{
            id:          fundraising.id,
            param:       "fundraising",
            slug:        "fundraising",
            name:        "Fundraising",
            email_address_tag: "fundraising",
            color:       "#bbbbbb",

            email_address:                fundraising.email_address,
            task_email_address:           fundraising.task_email_address,
            formatted_email_address:      fundraising.formatted_email_address,
            formatted_task_email_address: fundraising.formatted_task_email_address,

            links: {
              members:       "/api/organizations/#{raceteam.to_param}/groups/#{fundraising.to_param}/members",
              conversations: "/api/organizations/#{raceteam.to_param}/groups/#{fundraising.to_param}/conversations",
              tasks:         "/api/organizations/#{raceteam.to_param}/groups/#{fundraising.to_param}/tasks",
            },
          },
        ]
      )
    end
  end

end
