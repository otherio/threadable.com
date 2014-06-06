require 'spec_helper'

describe OrganizationsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:sfhealth) { threadable.organizations.find_by_slug!('sfhealth') }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  context 'when given a single record' do
    let(:payload){ raceteam }
    let(:alice) { raceteam.members.find_by_email_address('alice@ucsd.example.com') }
    let(:expected_key){ :organization }

    before do
      alice.external_authorizations.add_or_update!(
        provider: 'google_oauth2',
        token: 'foo',
        refresh_token: 'moar foo',
        name: 'Alice Neilson',
        email_address: 'alice@foo.com',
        domain: 'foo.com',
      )

      raceteam.google_user = alice
    end

    it do
      should eq(
        id:                raceteam.id,
        param:             "raceteam",
        name:              "UCSD Electric Racing",
        short_name:        "RaceTeam",
        slug:              "raceteam",
        subject_tag:       "RaceTeam",
        description:       "Senior engineering electric race team!",
        has_held_messages: false,
        trusted:           true,

        email_address_username:       raceteam.email_address_username,
        email_address:                raceteam.email_address,
        task_email_address:           raceteam.task_email_address,
        formatted_email_address:      raceteam.formatted_email_address,
        formatted_task_email_address: raceteam.formatted_task_email_address,

        groups: serialize(:groups, raceteam.groups.all).values.first,
        google_user: serialize(:users, alice).values.first,

        can_remove_non_empty_group:   true,
        can_be_google_user:           true,
        can_change_settings:          true,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [raceteam,sfhealth] }
    let(:expected_key){ :organizations }
    it do
      should eq [
        {
          id:                raceteam.id,
          param:             "raceteam",
          name:              "UCSD Electric Racing",
          short_name:        "RaceTeam",
          slug:              "raceteam",
          subject_tag:       "RaceTeam",
          description:       "Senior engineering electric race team!",
          has_held_messages: false,
          trusted:           true,

          email_address_username:       raceteam.email_address_username,
          email_address:                raceteam.email_address,
          task_email_address:           raceteam.task_email_address,
          formatted_email_address:      raceteam.formatted_email_address,
          formatted_task_email_address: raceteam.formatted_task_email_address,

          groups: serialize(:groups, raceteam.groups.all).values.first,
          google_user: nil,

          can_remove_non_empty_group:   true,
          can_be_google_user:          true,
          can_change_settings:          true,
        },{
          id:                sfhealth.id,
          param:             "sfhealth",
          name:              "SF Health Center",
          short_name:        "SFHealth",
          slug:              "sfhealth",
          subject_tag:       "SFHealth",
          description:       "San Francisco Health Center",
          has_held_messages: false,
          trusted:           false,

          email_address_username:       sfhealth.email_address_username,
          email_address:                sfhealth.email_address,
          task_email_address:           sfhealth.task_email_address,
          formatted_email_address:      sfhealth.formatted_email_address,
          formatted_task_email_address: sfhealth.formatted_task_email_address,

          groups: serialize(:groups, sfhealth.groups.all).values.first,
          google_user: nil,

          can_remove_non_empty_group:   false,
          can_be_google_user:          false,
          can_change_settings:          false,
        }
      ]
    end
  end

end
