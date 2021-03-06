require 'spec_helper'

describe Threadable::Organization, :type => :request do

  let(:organization_record){ find_organization_by_slug('raceteam') }
  let(:organization){ described_class.new(threadable, organization_record) }
  let(:primary_group) { raceteam.groups.primary }
  let(:billforward) { double(:billforward) }

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
      'raceteam+fundraising@localhost' => false,

      'fundraising@raceteam.localhost' => true,
      'raceteam@localhost'             => true,
      'press@ucsd.example.com'         => true,
    }

    examples.each do |email_address, expected_result|
      context "when given #{email_address.inspect}" do
        subject{ organization.has_email_address?(Mail::Address.new(email_address)) }
        it { is_expected.to eq(expected_result) }
      end
    end
  end

  describe '#matches_email_address?' do
    examples = {
      'Ian Baker <ian@other.io>'       => false,
      'ian@other.io'                   => false,
      'foo+bar@threadable.com'         => false,
      'foo@staging.threadable.com'     => false,

      'raceteam+fundraising@localhost'         => true,
      'raceteam@covered.io'                    => true,
      'raceteam@threadable.com'                => true,
      'raceteam+something@threadable.com'      => true,
      'press@ucsd.example.com'                 => true,
      'something@raceteam.threadable.com'      => true,
      'something+task@raceteam.threadable.com' => true,
      'raceteam--something@threadable.com'     => true,
      'raceteam--task@threadable.com'          => true,
    }

    examples.each do |email_address, expected_result|
      context "when given #{email_address.inspect}" do
        subject{ organization.matches_email_address?(Mail::Address.new(email_address)) }
        it { is_expected.to eq(expected_result) }
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
            "budget-worknight",
            "recruiting",  # access to this restricted using a different scope
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

      describe 'my.not_muted_conversations' do
        it "returns the non-muted conversations in bethany's groups" do
          conversations = organization.my.not_muted_conversations(0)
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
            "parts-for-the-motor-controller",
            "how-are-we-going-to-build-the-body",
            "drive-trains-are-expensive",
            "inventory-led-supplies",
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

  describe 'plans' do
    describe '#free?' do
      it 'tells us whether the org is free' do
        expect(organization.free?).to be_falsey
      end
    end

    describe '#paid?' do
      it 'tells us whether the org is paid' do
        expect(organization.paid?).to be_truthy
      end
    end
  end

  describe 'account types' do
    describe '#standard_account?' do
      it 'tells us whether the org is standard' do
        expect(organization.standard_account?).to be_truthy
      end
    end

    describe '#nonprofit_account?' do
      it 'tells us whether the org is nonprofit' do
        expect(organization.nonprofit_account?).to be_falsey
      end
    end

    describe '#yc_account?' do
      it 'tells us whether the org is yc' do
        expect(organization.yc_account?).to be_falsey
      end
    end
  end

  describe '#email_host' do
    it 'returns the email host' do
      expect(organization.email_host).to eq 'raceteam.localhost'
      expect(organization.internal_email_host).to eq 'raceteam.localhost'
    end

    context 'with a primary email domain' do
      let(:email_domain) { organization.email_domains.find_by_domain('raceteam.com') }

      before do
        sign_in_as 'alice@ucsd.example.com'
        email_domain.outgoing!
      end

      it 'returns the primary email domain' do
        expect(organization.email_host).to eq 'raceteam.com'
        expect(organization.internal_email_host).to eq 'raceteam.localhost'
      end
    end
  end

  describe '#email_address_tags' do
    let(:fundraising) { organization.groups.find_by_slug('fundraising') }

    before do
      fundraising.group_record.update_attributes(alias_email_address: 'cash@money.com')
    end

    examples = {
      ['foo@raceteam.localhost', 'raceteam+bar@threadable.com'] => ['foo', 'bar'],
      ['foo@raceteam.com', 'raceteam+bar@threadable.com'] => ['foo', 'bar'],
      ['raceteam+foo@covered.io', 'mom+bar@threadable.com'] => ['foo'],
      ['ian@mail.sonic.net'] => [],
      ['raceteam+bar+baz@threadable.com'] => ['bar', 'baz'],
      ['raceteam+bar+task@threadable.com'] => ['bar'],
      ['raceteam@localhost'] => ['raceteam'],
      ['press@ucsd.example.com'] => ['press'],
      ['cash@money.com'] => ['fundraising'],
      ['foo@money.com'] => [],
    }

    # this checks that the domain belongs to the specified organization,
    # but does not check to make sure the email address tag is a valid group.

    examples.each do |email_addresses, expected_result|
      context "when given #{email_addresses.inspect}" do
        subject{ organization.email_address_tags(email_addresses) }
        it { is_expected.to eq(expected_result) }
      end
    end

    context 'when the address has a period in it' do
      before do
        organization.organization_record.update_attribute(:email_address_username, 'race-team')
      end

      it 'properly translates to a dash' do
        organization.reload
        expect(organization.email_address_tags('race.team@localhost')).to eq ['raceteam']
        expect(organization.email_address_tags('race.team+things@localhost')).to eq ['things']
      end
    end
  end

  describe '#owner_ids' do
    let(:alice) { organization.members.find_by_email_address('alice@ucsd.example.com') }

    it 'returns the ids of all org owners' do
      expect(organization.owner_ids).to match_array [alice.id]
    end
  end

  describe '#last_message_at' do
    let(:conversation) { organization.conversations.latest }

    before do
      Timecop.freeze
      conversation.messages.create(body: 'a message')
    end

    it 'returns the time the last message qas created' do
      # to_i reduces the resolution to one second
      expect(organization.last_message_at.utc.to_i).to eq Time.now.utc.to_i
    end
  end

  it 'has the correct settings with proper defaults' do
    expect(organization.settings.organization_membership_permission).to eq :member
    expect(organization.settings.group_membership_permission).to eq :member
    expect(organization.settings.group_settings_permission).to eq :member
  end

end
