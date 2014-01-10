require 'spec_helper'

describe Api::OrganizationsSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:sfhealth) { covered.organizations.find_by_slug!('sfhealth') }

  context 'when given a single record' do
    subject{ described_class[raceteam] }
    it do
      should eq(
        organization: {
          id:          raceteam.id,
          param:       "raceteam",
          name:        "UCSD Electric Racing",
          short_name:  "RaceTeam",
          slug:        "raceteam",
          subject_tag: "RaceTeam",
          description: "Senior engineering electric race team!",

          email_address:                raceteam.email_address,
          task_email_address:           raceteam.task_email_address,
          formatted_email_address:      raceteam.formatted_email_address,
          formatted_task_email_address: raceteam.formatted_task_email_address,

          links: {
            members:       "/api/organizations/#{raceteam.slug}/members",
            groups:        "/api/organizations/#{raceteam.slug}/groups",
            conversations: "/api/organizations/#{raceteam.slug}/conversations",
            tasks:         "/api/organizations/#{raceteam.slug}/tasks",
          },
        }
      )
    end
  end

  context 'when given a collection of records' do
    subject{ described_class[[raceteam,sfhealth]] }
    it do
      should eq(
        organizations: [
          {
            id:          raceteam.id,
            param:       "raceteam",
            name:        "UCSD Electric Racing",
            short_name:  "RaceTeam",
            slug:        "raceteam",
            subject_tag: "RaceTeam",
            description: "Senior engineering electric race team!",

            email_address:                raceteam.email_address,
            task_email_address:           raceteam.task_email_address,
            formatted_email_address:      raceteam.formatted_email_address,
            formatted_task_email_address: raceteam.formatted_task_email_address,

            links: {
              members:       "/api/organizations/#{raceteam.slug}/members",
              groups:        "/api/organizations/#{raceteam.slug}/groups",
              conversations: "/api/organizations/#{raceteam.slug}/conversations",
              tasks:         "/api/organizations/#{raceteam.slug}/tasks",
            },
          },{
            id:          sfhealth.id,
            param:       "sfhealth",
            name:        "SF Health Center",
            short_name:  "SFHealth",
            slug:        "sfhealth",
            subject_tag: "SFHealth",
            description: "San Francisco Health Center",

            email_address:                sfhealth.email_address,
            task_email_address:           sfhealth.task_email_address,
            formatted_email_address:      sfhealth.formatted_email_address,
            formatted_task_email_address: sfhealth.formatted_task_email_address,

            links: {
              members:       "/api/organizations/#{sfhealth.slug}/members",
              groups:        "/api/organizations/#{sfhealth.slug}/groups",
              conversations: "/api/organizations/#{sfhealth.slug}/conversations",
              tasks:         "/api/organizations/#{sfhealth.slug}/tasks",
            },
          }
        ]
      )
    end
  end

end
