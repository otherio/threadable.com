require 'spec_helper'

describe Threadable::Organization do

  let(:organization_record){ find_organization_by_slug('raceteam') }
  let(:organization){ described_class.new(threadable, organization_record) }
  subject{ organization }


  describe 'destroy!' do
    it 'destroys the organization, organization memberships, conversations and messages' do
      organization_id = organization.id

      membership_ids   = organization_record.memberships.map(&:id)
      conversation_ids = organization_record.conversations.map(&:id)
      message_ids      = organization_record.messages.map(&:id)
      event_ids        = organization_record.events.map(&:id)

      organization.destroy!
      expect( ::Organization.where(id: organization_id)          ).to be_empty
      expect( ::OrganizationMembership.where(id: membership_ids) ).to be_empty
      expect( ::Conversation.where(id: conversation_ids)         ).to be_empty
      expect( ::Message.where(id: message_ids)                   ).to be_empty
      expect( ::Event.where(id: event_ids)                       ).to be_empty
    end
  end

  describe '#has_email_address?' do
    examples = {
      'Ian Baker <ian@other.io>'       => false,
      'ian@other.io'                   => false,
      'foo+bar@threadable.com'         => false,
      'foo@staging.threadable.com'     => false,

      'raceteam+fundraising@localhost' => true,
      'raceteam@localhost'             => true,
      'press@ucsd.example.com'         => true,
    }

    examples.each do |email_address, expected_result|
      context "when given #{email_address.inspect}" do
        subject{ organization.has_email_address?(Mail::Address.new(email_address)) }
        it { should == expected_result }
      end
    end
  end

  describe '#matches_email_address?' do
    examples = {
      'Ian Baker <ian@other.io>'       => false,
      'ian@other.io'                   => false,
      'foo+bar@threadable.com'         => false,
      'foo@staging.threadable.com'     => false,

      'raceteam+fundraising@localhost'    => true,
      'raceteam@covered.io'               => true,
      'raceteam@threadable.com'           => true,
      'raceteam+something@threadable.com' => true,
      'press@ucsd.example.com'            => true,
    }

    examples.each do |email_address, expected_result|
      context "when given #{email_address.inspect}" do
        subject{ organization.matches_email_address?(Mail::Address.new(email_address)) }
        it { should == expected_result }
      end
    end
  end

  describe 'scopes' do
    when_signed_in_as 'bethany@ucsd.example.com' do

      describe 'muted_conversations' do
        it "returns the conversations bethany has muted" do
          conversations = organization.muted_conversations(0)
          conversations.each do |conversation|
            expect(conversation).to be_a Threadable::Conversation
            expect(conversation).to be_muted_by current_user
          end

          expect( slugs_for conversations ).to match_array [
            "layup-body-carbon",
            "get-carbon-and-fiberglass",
            "get-release-agent",
            "get-epoxy",
            "parts-for-the-drive-train",
            "welcome-to-our-threadable-organization"
          ]
        end
      end
      describe 'not_muted_conversations' do
        it "returns the conversations bethany has not muted" do
          conversations = organization.not_muted_conversations(0)
          conversations.each do |conversation|
            expect(conversation).to be_a Threadable::Conversation
            expect(conversation).to_not be_muted_by current_user
          end
          expect( slugs_for conversations ).to match_array [
            "who-wants-to-pick-up-breakfast",
            "who-wants-to-pick-up-dinner",
            "who-wants-to-pick-up-lunch",
            "get-some-4-gauge-wire",
            "get-a-new-soldering-iron",
            "make-wooden-form-for-carbon-layup",
            "trim-body-panels",
            "install-mirrors",
            "how-are-we-paying-for-the-motor-controller",
            "parts-for-the-motor-controller",
            "how-are-we-going-to-build-the-body",
            "drive-trains-are-expensive",
            "inventory-led-supplies",
          ]
        end
      end
      describe 'done_tasks' do
        it "returns all the done tasks" do
          tasks = organization.done_tasks(0)
          tasks.each do |task|
            expect(task).to be_a Threadable::Task
            expect(task).to be_done
          end
          expect( slugs_for tasks ).to eq [
            "get-epoxy",
            "get-release-agent",
            "get-carbon-and-fiberglass",
            "layup-body-carbon",
          ]
        end
      end
      describe 'not_done_tasks' do
        it "returns all the not done tasks" do
          tasks = organization.not_done_tasks(0)
          tasks.each do |task|
            expect(task).to be_a Threadable::Task
            expect(task).to_not be_done
          end
          expect( slugs_for tasks ).to eq [
            "install-mirrors",
            "trim-body-panels",
            "make-wooden-form-for-carbon-layup",
            "get-a-new-soldering-iron",
            "get-some-4-gauge-wire",
            "inventory-led-supplies",
          ]
        end
      end
      describe 'done_doing_tasks' do
        it "returns all the done tasks bethany is doing" do
          tasks = organization.done_doing_tasks(0)
          tasks.each do |task|
            expect(task).to be_a Threadable::Task
            expect(task).to be_done
            expect(task).to be_being_done_by current_user
          end
          expect( slugs_for tasks ).to eq [

          ]
        end
      end
      describe 'not_done_doing_tasks' do
        it "returns all the not done tasks bethany is doing" do
          tasks = organization.not_done_doing_tasks(0)
          tasks.each do |task|
            expect(task).to be_a Threadable::Task
            expect(task).to_not be_done
            expect(task).to be_being_done_by current_user
          end
          expect( slugs_for tasks ).to eq [
            "get-a-new-soldering-iron",
          ]
        end
      end

    end

    def slugs_for collection
      collection.map(&:slug)
    end

  end

  describe '#google_user' do
    let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com') }
    before do
      organization_record.update_attributes(google_user: alice.user_record)
    end

    it 'returns the connected google user' do
      expect(organization.google_user).to eq Threadable::User.new(threadable, alice.user_record)
    end
  end

  describe '#google_user=' do
    context 'when the user has the correct permissions' do
      let(:user) { organization.members.find_by_email_address('alice@ucsd.example.com') }

      context 'when the user has an external authorization' do
        before do
          user.external_authorizations.add_or_update!(
            provider: 'google_oauth2',
            token: 'foo',
            refresh_token: 'moar foo',
            name: 'Bob Cauchois',
            email_address: 'bob@foo.com',
            domain: auth_domain,
          )
        end

        context 'and the authorization is good' do
          let(:auth_domain) { 'foo.com' }
          it 'sets the google sync user' do
            organization.google_user = user
            expect(organization.google_user).to eq Threadable::User.new(threadable, user.user_record)
          end
        end

        context 'and the auth lacks a domain' do
          let(:auth_domain) { nil }

          it 'fails with an error message' do
            expect{ organization.google_user = user }.to raise_error Threadable::ExternalServiceError, "User's Google authorization does not have a domain. Are they a google apps domain admin?"
          end
        end
      end

      context 'when the user does not have an external auth' do
        it 'fails with a different error message' do
          expect{ organization.google_user = user }.to raise_error Threadable::ExternalServiceError, 'User does not have a Google authorization'
        end
      end
    end

    context 'when the user does not have the correct permissions' do
      let(:user) { organization.members.find_by_email_address('bob@ucsd.example.com') }

      it 'sets the google sync user' do
        expect { organization.google_user = user }.to raise_error Threadable::AuthorizationError, 'User does not have permission to be the google apps domain user'
      end
    end

  end

end
