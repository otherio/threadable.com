require 'spec_helper'

describe BaseConversationsSerializer do

  let(:raceteam) { threadable.organizations.find_by_slug!('raceteam') }
  let(:layup_body_carbon) { raceteam.conversations.find_by_slug!('layup-body-carbon') }
  let(:welcome) { raceteam.conversations.find_by_slug!('welcome-to-our-threadable-organization') }
  let(:primary_group) { raceteam.groups.primary }

  context 'when not signed in' do
    context 'when given a single record' do
      let(:payload){ layup_body_carbon }
      let(:expected_key){ :conversation }
      it do
        is_expected.to eq(
          {
            id:                 layup_body_carbon.id,
            slug:               "layup-body-carbon",
            organization_slug:  "raceteam",
            subject:            "layup body carbon",
            task:               true,
            created_at:         layup_body_carbon.created_at,
            updated_at:         layup_body_carbon.updated_at,
            last_message_at:    layup_body_carbon.last_message_at,
            participant_names:  ["Alice", "Tom", "Yan", "Andy"],
            number_of_messages: 8,
            message_summary:    "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since we're under weight on the wheels anyway.\n\n> Wow, thanks Andy! Super helpful. I think we'll\n> just go for the carbon/glass like you suggested,\n> since we're under weight on the wheels anyway.\n"[0..50],
            group_ids:          [ primary_group.id ],
            doers:              serialize_model(:doers, layup_body_carbon.doers.all).values.first,
            done_at:            layup_body_carbon.done_at,
            done:               true,
            position:           layup_body_carbon.position,
            trashed_at:         nil,
            trashed:            false,
            follower_ids:       layup_body_carbon.follower_ids,
            muter_ids:          layup_body_carbon.muter_ids,
          }.merge(serialize_model(:doers, layup_body_carbon.doers.all))
        )
      end
    end
  end

end
