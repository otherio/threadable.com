require 'spec_helper'

describe LightOrganizationsSerializer do

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
      should eq(
        id:                raceteam.id,
        param:             "raceteam",
        name:              "UCSD Electric Racing",
        short_name:        "RaceTeam",
        slug:              "raceteam",
        subject_tag:       "RaceTeam",
        description:       "Senior engineering electric race team!",
        trusted:           true,
        plan:              :paid,
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
          trusted:           true,
          plan:              :paid,
        },{
          id:                sfhealth.id,
          param:             "sfhealth",
          name:              "SF Health Center",
          short_name:        "SFHealth",
          slug:              "sfhealth",
          subject_tag:       "SFHealth",
          description:       "San Francisco Health Center",
          trusted:           false,
          plan:              :free,
        }
      ]
    end
  end

end
