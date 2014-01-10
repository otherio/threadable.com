require 'spec_helper'

describe Api::TasksSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:layup_body_carbon) { raceteam.tasks.find_by_slug!('layup-body-carbon') }
  let(:trim_body_panels) { raceteam.tasks.find_by_slug!('trim-body-panels') }

  context 'when given a single record' do
    subject{ described_class[layup_body_carbon] }
    it do
      should eq(
        task: {
          id:                layup_body_carbon.id,
          param:             "layup-body-carbon",
          slug:              "layup-body-carbon",
          subject:           "layup body carbon",
          position:          1,
          done:              true,

          created_at:        layup_body_carbon.created_at,
          updated_at:        layup_body_carbon.updated_at,

          links: {
            conversations: "/api/organizations/#{raceteam.slug}/conversations/#{layup_body_carbon.slug}",
            messages:      "/api/organizations/#{raceteam.slug}/conversations/#{layup_body_carbon.slug}/messages",
            doers:         "/api/organizations/#{raceteam.slug}/tasks/#{layup_body_carbon.slug}/doers"
          },
        }
      )
    end
  end

  context 'when given a collection of records' do
    subject{ described_class[[trim_body_panels, layup_body_carbon]] }
    it do
      should eq(
        tasks: [
          {
            id:                trim_body_panels.id,
            param:             "trim-body-panels",
            slug:              "trim-body-panels",
            subject:           "trim body panels",
            position:          3,
            done:              false,

            created_at:        trim_body_panels.created_at,
            updated_at:        trim_body_panels.updated_at,

            links: {
              conversations: "/api/organizations/#{raceteam.slug}/conversations/#{trim_body_panels.slug}",
              messages:      "/api/organizations/#{raceteam.slug}/conversations/#{trim_body_panels.slug}/messages",
              doers:         "/api/organizations/#{raceteam.slug}/tasks/#{trim_body_panels.slug}/doers"
            },
          },{
            id:                layup_body_carbon.id,
            param:             "layup-body-carbon",
            slug:              "layup-body-carbon",
            subject:           "layup body carbon",
            position:          1,
            done:              true,

            created_at:        layup_body_carbon.created_at,
            updated_at:        layup_body_carbon.updated_at,

            links: {
              conversations: "/api/organizations/#{raceteam.slug}/conversations/#{layup_body_carbon.slug}",
              messages:      "/api/organizations/#{raceteam.slug}/conversations/#{layup_body_carbon.slug}/messages",
              doers:         "/api/organizations/#{raceteam.slug}/tasks/#{layup_body_carbon.slug}/doers"
            },
          }
        ]
      )
    end
  end

end
