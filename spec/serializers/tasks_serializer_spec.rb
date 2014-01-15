require 'spec_helper'

describe TasksSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:layup_body_carbon) { raceteam.tasks.find_by_slug!('layup-body-carbon') }
  let(:trim_body_panels) { raceteam.tasks.find_by_slug!('trim-body-panels') }

  context 'when given a single record' do
    let(:payload){ layup_body_carbon }
    let(:expected_key){ :task }
    it do
      should eq(
        id:         layup_body_carbon.id,
        param:      "layup-body-carbon",
        slug:       "layup-body-carbon",
        subject:    "layup body carbon",
        position:   1,
        done:       true,

        created_at: layup_body_carbon.created_at,
        updated_at: layup_body_carbon.updated_at,
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [trim_body_panels, layup_body_carbon] }
    let(:expected_key){ :tasks }
    it do
      should eq [
        {
          id:         trim_body_panels.id,
          param:      "trim-body-panels",
          slug:       "trim-body-panels",
          subject:    "trim body panels",
          position:   3,
          done:       false,

          created_at: trim_body_panels.created_at,
          updated_at: trim_body_panels.updated_at,
        },{
          id:         layup_body_carbon.id,
          param:      "layup-body-carbon",
          slug:       "layup-body-carbon",
          subject:    "layup body carbon",
          position:   1,
          done:       true,

          created_at: layup_body_carbon.created_at,
          updated_at: layup_body_carbon.updated_at,
        }
      ]
    end
  end

end
