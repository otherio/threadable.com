require 'spec_helper'

describe OrganizationsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:sfhealth) { threadable.organizations.find_by_slug!('sfhealth') }
  let(:alice)    { raceteam.members.find_by_email_address('alice@ucsd.example.com') }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  context 'when given a single record' do
    let(:payload){ raceteam }
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
      is_expected.to eq(
        id:                raceteam.id,
        param:             "raceteam",
        name:              "UCSD Electric Racing",
        short_name:        "RaceTeam",
        slug:              "raceteam",
        subject_tag:       "RaceTeam",
        description:       "Senior engineering electric race team!",
        has_held_messages: false,
        trusted:           true,
        plan:              :paid,
        public_signup:     true,
        account_type:      :standard_account,

        email_address_username:       raceteam.email_address_username,
        email_address:                raceteam.email_address,
        task_email_address:           raceteam.task_email_address,
        formatted_email_address:      raceteam.formatted_email_address,
        formatted_task_email_address: raceteam.formatted_task_email_address,

        groups:        serialize_model(:groups, raceteam.groups.all).values.first,
        email_domains: serialize_model(:email_domains, raceteam.email_domains.all).values.first,
        google_user:   serialize_model(:users, alice).values.first,

        can_remove_non_empty_group:   true,
        can_be_google_user:           true,
        can_change_settings:          true,
        can_invite_members:           true,
        can_make_private_groups:      true,
        can_read_private_groups:      true,

        organization_membership_permission: :member,
        group_membership_permission:        :member,
        group_settings_permission:          :member,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [raceteam,sfhealth] }
    let(:expected_key){ :organizations }

    before do
      # you have to be a member of an org to list its groups
      sign_in_as 'amywong.phd@gmail.com'
      sfhealth.members.add(email_address: 'alice@ucsd.example.com')
      sign_in_as 'alice@ucsd.example.com'
    end

    it do
      is_expected.to eq [
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
          plan:              :paid,
          public_signup:     true,
          account_type:      :standard_account,

          email_address_username:       raceteam.email_address_username,
          email_address:                raceteam.email_address,
          task_email_address:           raceteam.task_email_address,
          formatted_email_address:      raceteam.formatted_email_address,
          formatted_task_email_address: raceteam.formatted_task_email_address,

          groups:        serialize_model(:groups, raceteam.groups.all).values.first,
          email_domains: serialize_model(:email_domains, raceteam.email_domains.all).values.first,
          google_user:   nil,

          can_remove_non_empty_group:   true,
          can_be_google_user:           true,
          can_change_settings:          true,
          can_invite_members:           true,
          can_make_private_groups:      true,
          can_read_private_groups:      true,

          organization_membership_permission: :member,
          group_membership_permission:        :member,
          group_settings_permission:          :member,
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
          plan:              :paid,
          public_signup:     false,
          account_type:      :standard_account,

          email_address_username:       sfhealth.email_address_username,
          email_address:                sfhealth.email_address,
          task_email_address:           sfhealth.task_email_address,
          formatted_email_address:      sfhealth.formatted_email_address,
          formatted_task_email_address: sfhealth.formatted_task_email_address,

          groups:        serialize_model(:groups, sfhealth.groups.all).values.first,
          email_domains: serialize_model(:email_domains, sfhealth.email_domains.all).values.first,
          google_user:   nil,

          can_remove_non_empty_group:   false,
          can_be_google_user:           false,
          can_change_settings:          false,
          can_invite_members:           true,
          can_make_private_groups:      true,
          can_read_private_groups:      false,

          organization_membership_permission: :member,
          group_membership_permission:        :member,
          group_settings_permission:          :member,
        }
      ]
    end
  end

end
