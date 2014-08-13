require 'spec_helper'

describe GroupsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:electronics) { raceteam.groups.find_by_email_address_tag!('electronics') }
  let(:fundraising) { raceteam.groups.find_by_email_address_tag!('fundraising') }

  before{ sign_in_as 'alice@ucsd.example.com' }

  context 'when given a single record' do
    let(:payload){ electronics }
    let(:expected_key){ :group }
    it do
      should eq(
        id:                  electronics.id,
        slug:                "electronics",
        name:                "Electronics",
        email_address_tag:   "electronics",
        subject_tag:         "RaceTeam+Electronics",
        alias_email_address: '',
        webhook_url:         '',
        color:               "#964bf8",
        auto_join:           false,
        hold_messages:       true,
        description:         'Soldering and wires and stuff!',
        google_sync:         false,
        primary:             false,

        email_address:                electronics.email_address,
        task_email_address:           electronics.task_email_address,
        formatted_email_address:      electronics.formatted_email_address,
        formatted_task_email_address: electronics.formatted_task_email_address,
        internal_email_address:       electronics.internal_email_address,
        internal_task_email_address:  electronics.internal_task_email_address,

        conversations_count:          electronics.conversations.count,
        members_count:                electronics.members.count,
        organization_slug:            electronics.organization.slug,

        current_user_is_a_member: false,
        current_user_is_a_limited_member: false,
        can_set_google_sync:      true,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [electronics, fundraising] }
    let(:expected_key){ :groups }
    it do
      should eq [
        {
          id:                  electronics.id,
          slug:                "electronics",
          name:                "Electronics",
          email_address_tag:   "electronics",
          subject_tag:         "RaceTeam+Electronics",
          alias_email_address: '',
          webhook_url:         '',
          color:               "#964bf8",
          auto_join:           false,
          hold_messages:       true,
          description:         'Soldering and wires and stuff!',
          google_sync:         false,
          primary:             false,

          email_address:                electronics.email_address,
          task_email_address:           electronics.task_email_address,
          formatted_email_address:      electronics.formatted_email_address,
          formatted_task_email_address: electronics.formatted_task_email_address,
          internal_email_address:       electronics.internal_email_address,
          internal_task_email_address:  electronics.internal_task_email_address,

          conversations_count:          electronics.conversations.count,
          members_count:                electronics.members.count,
          organization_slug:            electronics.organization.slug,

          current_user_is_a_member: false,
          current_user_is_a_limited_member: false,
          can_set_google_sync:      true,
        },{
          id:                  fundraising.id,
          slug:                "fundraising",
          name:                "Fundraising",
          email_address_tag:   "fundraising",
          subject_tag:         "RaceTeam+Fundraising",
          alias_email_address: '',
          webhook_url:         '',
          color:               "#5a9de1",
          auto_join:           false,
          hold_messages:       true,
          description:         'Cache Monet',
          google_sync:         false,
          primary:             false,

          email_address:                fundraising.email_address,
          task_email_address:           fundraising.task_email_address,
          formatted_email_address:      fundraising.formatted_email_address,
          formatted_task_email_address: fundraising.formatted_task_email_address,
          internal_email_address:       fundraising.internal_email_address,
          internal_task_email_address:  fundraising.internal_task_email_address,

          conversations_count:          fundraising.conversations.count,
          members_count:                fundraising.members.count,
          organization_slug:            fundraising.organization.slug,

          current_user_is_a_member: true,
          current_user_is_a_limited_member: false,
          can_set_google_sync:      true,
        },
      ]
    end
  end

end
