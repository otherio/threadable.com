require 'spec_helper'

describe GroupsSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:electronics) { raceteam.groups.find_by_email_address_tag!('electronics') }
  let(:fundraising) { raceteam.groups.find_by_email_address_tag!('fundraising') }

  context 'when given a single record' do
    let(:payload){ electronics }
    it do
      should eq(
        group: {
          id:          electronics.id,
          param:       "electronics",
          slug:        "electronics",
          name:        "Electronics",
          email_address_tag: "electronics",
          color:       "#964bf8",

          email_address:                electronics.email_address,
          task_email_address:           electronics.task_email_address,
          formatted_email_address:      electronics.formatted_email_address,
          formatted_task_email_address: electronics.formatted_task_email_address,

          conversations_count:          electronics.conversations.count,
          organization_slug:            electronics.organization.slug,

          current_user_is_a_member: false,
        }
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [electronics, fundraising] }
    it do
      should eq(
        groups: [
          {
            id:          electronics.id,
            param:       "electronics",
            slug:        "electronics",
            name:        "Electronics",
            email_address_tag: "electronics",
            color:       "#964bf8",

            email_address:                electronics.email_address,
            task_email_address:           electronics.task_email_address,
            formatted_email_address:      electronics.formatted_email_address,
            formatted_task_email_address: electronics.formatted_task_email_address,

            conversations_count:          electronics.conversations.count,
            organization_slug:            electronics.organization.slug,

            current_user_is_a_member: false,
          },{
            id:          fundraising.id,
            param:       "fundraising",
            slug:        "fundraising",
            name:        "Fundraising",
            email_address_tag: "fundraising",
            color:       "#5a9de1",

            email_address:                fundraising.email_address,
            task_email_address:           fundraising.task_email_address,
            formatted_email_address:      fundraising.formatted_email_address,
            formatted_task_email_address: fundraising.formatted_task_email_address,

            conversations_count:          fundraising.conversations.count,
            organization_slug:            fundraising.organization.slug,

            current_user_is_a_member: false,
          },
        ]
      )
    end


    context "when signed in as alice" do
      before{ sign_in_as 'alice@ucsd.example.com' }
      it do
        should eq(
          groups: [
            {
              id:          electronics.id,
              param:       "electronics",
              slug:        "electronics",
              name:        "Electronics",
              email_address_tag: "electronics",
              color:       "#964bf8",

              email_address:                electronics.email_address,
              task_email_address:           electronics.task_email_address,
              formatted_email_address:      electronics.formatted_email_address,
              formatted_task_email_address: electronics.formatted_task_email_address,

              conversations_count:          electronics.conversations.count,
              organization_slug:            electronics.organization.slug,

              current_user_is_a_member: false,
            },{
              id:          fundraising.id,
              param:       "fundraising",
              slug:        "fundraising",
              name:        "Fundraising",
              email_address_tag: "fundraising",
              color:       "#5a9de1",

              email_address:                fundraising.email_address,
              task_email_address:           fundraising.task_email_address,
              formatted_email_address:      fundraising.formatted_email_address,
              formatted_task_email_address: fundraising.formatted_task_email_address,

              conversations_count:          fundraising.conversations.count,
              organization_slug:            fundraising.organization.slug,

              current_user_is_a_member: true,
            },
          ]
        )
      end
    end
  end

end