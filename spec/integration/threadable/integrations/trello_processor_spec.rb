require 'spec_helper'

describe Threadable::Integrations::TrelloProcessor do

  delegate :call, to: described_class

  let(:organization) { threadable.organizations.find_by_slug!('raceteam') }
  let(:group) { organization.groups.find_by_slug('fundraising') }
  let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com')}
  let(:request) { nil }

  let(:incoming_integration_hook) { threadable.incoming_integration_hooks.create!(organization, group, request, params) }

  describe '#call' do
    let(:params) do
      {
        "provider" => "trello",
        'integration_hook' => {
          "action" => {
            "id" => "53221964bfce280557dd5698",
            "idMemberCreator" => "50a489d6cd04b2e83400b6ea",
            "data" => action_data,
            "type" => action_type,
            "date" => "2014-03-16T03:14:59.371Z",
            "memberCreator" => {
              "id" => "USER_ID",
              "avatarHash" => "e9336c46b73a5cff14ff49632d18c6d0",
              "fullName" => "Ian Baker",
              "initials" => "IB",
              "username" => "raindrift"
            }
          },
          "model" => {
            "id" => "531a791c8becd0342196fa8f",
            "name" => "Ian's Test Board",
            "desc" => "",
            "descData" => nil,
            "closed" => false,
            "idOrganization" => "50f37557d6a75efa390083ed",
            "pinned" => true,
            "url" => "https => //trello.com/b/Kqj1ETPQ/ian-s-test-board",
            "shortUrl" => "https => //trello.com/b/Kqj1ETPQ",
            "prefs" => {
              "permissionLevel" => "org",
              "voting" => "disabled",
              "comments" => "members",
              "invitations" => "members",
              "selfJoin" => false,
              "cardCovers" => true,
              "cardAging" => "regular",
              "background" => "blue",
              "backgroundColor" => "#23719F",
              "backgroundImage" => nil,
              "backgroundImageScaled" => nil,
              "backgroundTile" => false,
              "backgroundBrightness" => "unknown",
              "canBePublic" => true,
              "canBeOrg" => true,
              "canBePrivate" => true,
              "canInvite" => true
            },
            "labelNames" => {
              "red" => "",
              "orange" => "",
              "yellow" => "",
              "green" => "",
              "blue" => "",
              "purple" => ""
            }
          }
        }
      }
    end

    context 'when the request does not have a valid signature' do
      it 'raises an exception'
    end

    context 'when the user is authenticated against trello' do
      before do
        alice.external_authorizations.add_or_update!(
          provider: 'trello',
          token: 'foo',
          secret: 'bar',
          name: 'Alice Neilson',
          email_address: 'alice@foo.com',
          nickname: 'alice',
          url: 'http://foo.com/',
          unique_id: 'USER_ID'
        )
      end

      describe 'new card' do
        let(:action_type) { 'createCard' }
        let(:action_data) do
          {
            "board" => {
              "shortLink" => "Kqj1ETPQ",
              "name" => "Ian's Test Board",
              "id" => "531a791c8becd0342196fa8f"
            },
            "list" => {
              "name" => "To Do",
              "id" => "531a791c8becd0342196fa90"
            },
            "card" => {
              "shortLink" => "qdkDWQcY",
              "idShort" => 12,
              "name" => "This is a card",
              "id" => "CARD_ID"
            }
          }
        end

        it 'makes a new conversation for the new card' do
          call(incoming_integration_hook)
          conversation = group.conversations.find_by_slug('this-is-a-card')
          expect(conversation.creator).to eq alice
          expect(conversation.subject).to eq 'This is a card'
          expect(conversation.external_id).to eq 'CARD_ID'
        end

      end

      describe 'update card description' do
        let(:action_type) { 'updateCard' }
        let(:old) { {'desc' => '' } }
        let(:action_data) do
          {
            "board"=> {
              "shortLink"=>"Kqj1ETPQ",
              "name"=>"Ian's Test Board",
              "id"=>"531a791c8becd0342196fa8f"
            },
            "card"=> {
              "shortLink"=>"fSofuJyA",
              "idShort"=>15,
              "name" => "This is a card",
              "id"=>"CARD_ID",
              "desc"=>"The card description."
            },
            "old"=> old
          }
        end

        it 'creates the conversation and makes a new message' do
          call(incoming_integration_hook)
          conversation = group.conversations.find_by_slug('this-is-a-card')

          expect(conversation.creator).to eq alice
          expect(conversation.subject).to eq 'This is a card'
          expect(conversation.external_id).to eq 'CARD_ID'

          message = conversation.messages.all.first
          expect(message.subject).to eq 'This is a card'
          expect(message.body_plain).to include 'The card description'
          expect(message.date_header).to eq 'Sun, 16 Mar 2014 03:14:59 -0000'
        end

        context 'when the conversation already exists' do
          before do
            organization.conversations.create!(subject: 'existing subject', groups: [group], external_id: 'CARD_ID')
          end

          it 'finds the existing conversation' do
            call(incoming_integration_hook)
            expect(group.conversations.find_by_slug('this-is-a-card')).to_not be
            conversation = group.conversations.find_by_slug('existing-subject')
            expect(conversation.messages.all.length).to eq 1
          end
        end

        context 'for an update to a field we do not use' do
          let(:old) { {"due"=>nil} }

          it 'does nothing' do
            call(incoming_integration_hook)
            expect(group.conversations.find_by_slug('this-is-a-card')).to_not be
          end
        end
      end

      describe 'new card comment' do
        let(:action_type) { 'commentCard' }
        let(:action_data) do
          {
            "board"=> {
              "shortLink"=>"Kqj1ETPQ",
              "name"=>"Ian's Test Board",
              "id"=>"531a791c8becd0342196fa8f"
            },
             "card"=> {
              "shortLink"=>"fSofuJyA",
              "idShort"=>15,
              "name" => "This is a card",
              "id"=>"CARD_ID"
              },
            "text"=>"I am a comment."
          }
        end

        it 'creates the conversation and makes a new message' do
          call(incoming_integration_hook)
          conversation = group.conversations.find_by_slug('this-is-a-card')

          expect(conversation).to be
          expect(conversation.creator).to eq alice
          expect(conversation.subject).to eq 'This is a card'
          expect(conversation.external_id).to eq 'CARD_ID'

          message = conversation.messages.all.first
          expect(message.subject).to eq 'This is a card'
          expect(message.body_plain).to include 'I am a comment.'
          expect(message.date_header).to eq 'Sun, 16 Mar 2014 03:14:59 -0000'
        end
      end
    end

    context 'when the user is not authenticated with trello' do
      it 'looks up the user by their email address'

      context 'when the user cannot be found' do
        it 'uses the email address without setting a creator'
      end

    end
  end
end
