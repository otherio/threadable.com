require 'spec_helper'

describe ConversationDetailsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:layup_body_carbon) { raceteam.conversations.find_by_slug!('layup-body-carbon') }
  let(:welcome) { raceteam.conversations.find_by_slug!('welcome-to-our-threadable-organization') }
  let(:primary_group) { raceteam.groups.primary }

  before do
    sign_in_as 'alice@ucsd.example.com'
  end

  context 'when given a single record' do
    let(:payload){ layup_body_carbon }
    let(:expected_key){ :conversation_detail }
    it do
      is_expected.to eq(
        {
          id:                 layup_body_carbon.id,
          slug:               "layup-body-carbon",
          recipient_ids:      layup_body_carbon.recipients.all.map(&:id),
          muter_count:        layup_body_carbon.muter_ids.length,
          follower_ids:       layup_body_carbon.follower_ids,
        }
      )
    end
  end

  context 'when given a collection of records' do
    let(:payload){ [welcome, layup_body_carbon] }
    let(:expected_key){ :conversation_details }
    it do
      is_expected.to eq [
        {
          id:                 welcome.id,
          slug:               "welcome-to-our-threadable-organization",
          recipient_ids:      welcome.recipients.all.map(&:id),
          muter_count:        welcome.muter_ids.length,
          follower_ids:       welcome.follower_ids,
        },{
          id:                 layup_body_carbon.id,
          slug:               "layup-body-carbon",
          recipient_ids:      layup_body_carbon.recipients.all.map(&:id),
          muter_count:        layup_body_carbon.muter_ids.length,
          follower_ids:       layup_body_carbon.follower_ids,
        }
      ]
    end
  end

end
