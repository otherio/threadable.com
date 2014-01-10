require 'spec_helper'

describe Api::ConversationsSerializer do

  let(:raceteam) { covered.organizations.find_by_slug!('raceteam') }
  let(:layup_body_carbon) { raceteam.conversations.find_by_slug!('layup-body-carbon') }
  let(:welcome) { raceteam.conversations.find_by_slug!('welcome-to-our-covered-organization') }

  context 'when given a single record' do
    subject{ described_class[layup_body_carbon] }
    it do
      should eq(
        conversation: {
          id:                layup_body_carbon.id,
          param:             "layup-body-carbon",
          slug:              "layup-body-carbon",
          subject:           "layup body carbon",
          task:              true,
          created_at:        layup_body_carbon.created_at,
          updated_at:        layup_body_carbon.updated_at,
          participant_names: ["Alice", "Tom", "Yan", "Andy"],
          number_of_messages: 8,
          message_summary:   "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since we're under weight on the wheels anyway.\n\n> Wow, thanks Andy! Super helpful. I think we'll\n> just go for the carbon/glass like you suggested,\n> since we're under weight on the wheels anyway.\n",
          group_ids:          [],
          links: {
            messages: "/api/organizations/raceteam/conversations/layup-body-carbon/messages"
          },
        }
      )
    end
  end

  context 'when given a collection of records' do
    subject{ described_class[[welcome, layup_body_carbon]] }
    it do
      should eq(
        conversations: [
          {
            id:                 welcome.id,
            param:              "welcome-to-our-covered-organization",
            slug:               "welcome-to-our-covered-organization",
            subject:            "Welcome to our Covered organization!",
            task:               false,
            created_at:         welcome.created_at,
            updated_at:         welcome.updated_at,
            participant_names:  ["Alice", "Bethany"],
            number_of_messages: 2,
            message_summary:    "Yay! You go Alice. This tool looks radder than an 8-legged panda.",
            group_ids:          [],
            links: {
              messages: "/api/organizations/raceteam/conversations/welcome-to-our-covered-organization/messages"
            },
          },{
            id:                layup_body_carbon.id,
            param:             "layup-body-carbon",
            slug:              "layup-body-carbon",
            subject:           "layup body carbon",
            task:              true,
            created_at:        layup_body_carbon.created_at,
            updated_at:        layup_body_carbon.updated_at,
            participant_names: ["Alice", "Tom", "Yan", "Andy"],
            number_of_messages: 8,
            message_summary:   "This turned out super awesome! Yan and Bethany and I stayed til 8pm doing the layup and fitting everything on the vacuum table. The pieces are curing in the oven now, but we got some photos of them before they went in. Bethany got epoxy everywhere! It was pretty funny.\n\n Wow, thanks Andy! Super helpful. I think we'll just go for the carbon/glass\n like you suggested, since we're under weight on the wheels anyway.\n\n> Wow, thanks Andy! Super helpful. I think we'll\n> just go for the carbon/glass like you suggested,\n> since we're under weight on the wheels anyway.\n",
            group_ids:          [],
            links: {
              messages: "/api/organizations/raceteam/conversations/layup-body-carbon/messages"
            },
          }
        ]
      )
    end
  end

end
