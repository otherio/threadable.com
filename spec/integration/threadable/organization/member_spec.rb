require 'spec_helper'

describe Threadable::Organization::Member do
  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:member){ organization.members.find_by_email_address('bethany@ucsd.example.com') }
  subject{ member }

  context 'when signed in as an organization owner' do
    before{ sign_in_as 'alice@ucsd.example.com' }

    describe '#update' do

      it 'updates both the user record and the organization membership record' do
        member.update(
          subscribed: false,
          role: :member,
          ungrouped_mail_delivery: :no_mail,
          name: 'Bethany the great',
        )
        expect(member.subscribed?).to be_false
        expect(member.role).to eq :member
        expect(member.ungrouped_mail_delivery).to eq :no_mail
        expect(member.name).to eq 'Bethany the great'

        assert_tracked(current_user.id, "Unsubscribed",
          "Member user id"    => member.user_id,
          "Organization"      => organization.id,
          "Organization Name" => organization.name,
        )
        assert_tracked(current_user.id, "Ungrouped mail delivery changed",
          "Member user id"    => member.user_id,
          "Organization"      => organization.id,
          "Organization Name" => organization.name,
          "from"              => :each_message,
          "to"                => :no_mail,
        )
      end

      context 'when updating your own role' do
        let(:member){ organization.members.find_by_email_address('alice@ucsd.example.com') }
        it 'raises a Threadable::AuthorizationError' do
          expect{ member.update(role: :member) }.to raise_error Threadable::AuthorizationError, 'You cannot change your own organization membership role'
        end
      end

      context "when updating another member's role" do
        it 'updates updates the role' do
          expect{ member.update(role: :member) }.to_not raise_error
          expect(member.role).to eq :member
        end
      end
    end

  end

  context 'when signed in as an organization member' do
    before{ sign_in_as 'tom@ucsd.example.com' }

    describe '#update' do
      context 'when updating your own role' do
        let(:member){ organization.members.find_by_email_address('alice@ucsd.example.com') }
        it 'raises a Threadable::AuthorizationError' do
          expect{ member.update(role: :member) }.to raise_error Threadable::AuthorizationError, 'You are not authorized to change organization membership roles'
        end
      end

      context "when updating another member's role" do
        it 'raises a Threadable::AuthorizationError' do
          expect{ member.update(role: :owner) }.to raise_error Threadable::AuthorizationError, 'You are not authorized to change organization membership roles'
        end
      end
    end

  end

  describe '#summarized_conversations' do
    let(:time) { Time.zone.local(2014, 2, 2).utc }

    before do
      Time.zone = 'US/Pacific'
    end

    context 'when ungrouped should be summarized' do
      let(:member) { organization.members.find_by_email_address('ricky.bobby@ucsd.example.com')}
      it 'fetches the conversations to be summarized for a given date' do
        conversations = member.summarized_conversations(time)
        expect(conversations.map(&:slug)).to match_array [
          "how-are-we-going-to-build-the-body",
          "layup-body-carbon",
          "who-wants-to-pick-up-breakfast",
          "who-wants-to-pick-up-dinner",
          "who-wants-to-pick-up-lunch",
        ]
      end
    end

    context 'with groups that should be summarized' do
      let(:member) { organization.members.find_by_email_address('bob@ucsd.example.com')}
      it 'fetches the conversations to be summarized for a given date' do
        conversations = member.summarized_conversations(time)
        expect(conversations.map(&:slug)).to match_array [
          "drive-trains-are-expensive",
          "how-are-we-paying-for-the-motor-controller",
          "inventory-led-supplies",
        ]
      end
    end
  end

  describe '#remove' do
    context "when the current user is an owner" do
      let(:joined_group) { organization.groups.find_by_email_address_tag('electronics') }
      let(:doing_task) { organization.tasks.find_by_slug('get-a-new-soldering-iron') }

      before{ sign_in_as 'alice@ucsd.example.com' }

      it 'sets the member to inactive, removes them from groups, and makes them no longer a doer of any tasks' do
        member.remove
        expect(member.organization_membership_record.active).to be_false
        expect(organization.members.find_by_email_address('bethany@ucsd.example.com')).to be_nil

        expect(joined_group.members.all.map(&:id)).to_not include member.id
        expect(joined_group.members.count).to eq 1

        expect(doing_task.doers.all.map(&:id)).to_not include member.id
        expect(doing_task.doers.count).to eq 0
      end
    end

    context "when the current user is not an owner" do
      before{ sign_in_as 'bob@ucsd.example.com' }

      it 'raises an exception' do
        expect { member.remove }.to raise_error Threadable::AuthorizationError, 'You cannot remove members from this organization'
      end
    end
  end


end
