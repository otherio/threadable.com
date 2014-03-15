require 'spec_helper'

describe Threadable::Integrations::TrelloProcessor do

  delegate :call, to: described_class

  let(:organization) { threadable.organizations.find_by_slug!('raceteam') }
  let(:group) { organization.groups.find_by_slug('fundraising') }
  let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com')}
  let(:request) { nil }

  let(:incoming_integration_hook) { threadable.incoming_integration_hooks.create!(organization, group, request, params) }

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

  describe '#call' do
    let(:params) do
      {
        "provider" => "trello",
        "action" => {
          "id" => "53221964bfce280557dd5698",
          "idMemberCreator" => "50a489d6cd04b2e83400b6ea",
          "data" => action_data,
          "type" => action_type,
          "date" => "2014-03-13T20 => 47 => 32.100Z",
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
    end

    context 'when the request does not have a valid signature' do
      it 'raises an exception'
    end

    context 'when the user is authenticated against trello' do
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
          expect(conversation).to be
          expect(conversation.creator).to eq alice
          expect(conversation.subject).to eq 'This is a card'
          expect(conversation.external_id).to eq 'CARD_ID'
        end

      end

      # describe 'new comment' do
      #   let(:action_type) { 'something about creating a comment' }
      #   let(:action_data) do
      #     {
      #       list: {name: 'To Do', id: 'list_id' },
      #       card: {name: 'A Card', id: 'card_id' },
      #     }.stringify_keys
      #   end

      #   it 'makes a new conversation for the card, or updates an existing one' do
      #     call(incoming_integration_hook)
      #     conversation = group.conversations.find_by_slug('a-card')
      #     expect(conversation.messages.length).to eq 1
      #   end

      # end
    end

    context 'when the user is not authenticated with trello' do
      it 'looks up the user by their email address'

      context 'when the user cannot be found' do
        it 'uses the email address without setting a creator'
      end

    end

  end
end
