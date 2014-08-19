require 'spec_helper'

describe Threadable::Organization::Members::Add do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }

  describe '#call' do
    let(:auto_join_group) { organization.groups.find_by_email_address_tag('graphic-design') }
    let(:non_auto_join_group) { organization.groups.find_by_email_address_tag('electronics') }

    when_not_signed_in do
      context 'when the organization is not public' do
        before do
          organization.organization_record.update_attribute(:public_signup, false)
        end

        it 'raises an error' do
          expect{
            organization.members.add(email_address: 'pete.tong@example.com', name: 'Pete Tong')
          }.to raise_error(Threadable::AuthorizationError)
        end
      end

      context 'when the organization allows public signup' do
        it 'creates a new user adds them to the organization' do
          expect{
            organization.members.add(email_address: 'pete.tong@example.com', name: 'Pete Tong')
          }.to change{ User.count }.by(1)
        end
      end
    end

    when_signed_in_as 'lcuddy@sfhealth.example.com' do

      context "when given an existing user's email address" do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }
        it 'adds that user to the organization and all auto-joins groups but does not email our group add notices' do
          expect{
            organization.members.add(email_address: 'amywong.phd@gmail.com', name: 'Amy Wong')
          }.to_not change{ User.count }
          expect_organization_member! "amywong.phd@gmail.com"
        end
      end

      context 'when given an unseen email address' do
        let(:user) { threadable.users.find_by_email_address('pete.tong@example.com') }
        it 'creates a new user adds them to the organization' do
          expect{
            organization.members.add(email_address: 'pete.tong@example.com', name: 'Pete Tong')
          }.to change{ User.count }.by(1)
          expect_organization_member! 'pete.tong@example.com'
        end
      end

      context 'when given an unknown user id' do
        it 'creates a new user adds them to the organization' do
          expect{
            organization.members.add(user_id: 234321321321321)
          }.to raise_error Threadable::RecordNotFound, 'unable to find user with id: 234321321321321'
        end
      end

      context "when given a known user id" do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }
        it 'adds that user to the organization and all auto-joins groups but does not email our group add notices' do
          expect{
            organization.members.add(user_id: user.user_id)
          }.to_not change{ User.count }
          expect_organization_member! "amywong.phd@gmail.com"
        end
      end

      context "when given a user object" do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }
        it 'adds that user to the organization and all auto-joins groups but does not email our group add notices' do
          expect{
            organization.members.add(user: user)
          }.to_not change{ User.count }
          expect_organization_member! "amywong.phd@gmail.com"
        end
      end

      context "when given a user who was previously an organization member, but was deleted" do
        let(:user) { threadable.users.find_by_email_address('darth@ucsd.example.com') }
        it 'adds that user to the organization and all auto-joina groups but does not email our group add notices' do
          expect{
            organization.members.add(user: user)
          }.to_not change{ User.count }
          expect_organization_member! "darth@ucsd.example.com"
        end
      end

      describe 'confirmed option' do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }

        context 'when the org is untrusted' do
          before do
            organization.organization_record.update_attribute(:trusted, false)
          end

          it 'allows you to override the the organization trusted flag' do
            expect(organization.trusted?).to be_false
            organization.members.add(user: user, confirmed: true)
            expect(organization.members.find_by_email_address('amywong.phd@gmail.com').confirmed?).to be_true
          end
        end

        context 'when the org is trusted' do
          it 'allows you to override the the organization trusted flag' do
            expect(organization.trusted?).to be_true
            organization.members.add(user: user, confirmed: false)
            expect(organization.members.find_by_email_address('amywong.phd@gmail.com').confirmed?).to be_false
          end
        end
      end

      describe 'joined_notice option' do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }

        it 'sends self_join_notice' do
          organization.members.add(user: user, join_notice: :self_join_notice)
          expect( sent_emails.with_subject("You've added yourself to UCSD Electric Racing").sent_to('amywong.phd@gmail.com') ).to be
        end

        it 'sends self_join_notice_with_confirmation' do
          organization.members.add(user: user, join_notice: :self_join_notice_confirm)
          expect( sent_emails.with_subject("Confirm your membership in UCSD Electric Racing").sent_to('amywong.phd@gmail.com') ).to be
        end
      end
    end
  end


  def expect_organization_member! email_address
    user = threadable.users.find_by_email_address(email_address)

    expect( organization.members        ).to     include user
    expect( auto_join_group.members     ).to     include user
    expect( non_auto_join_group.members ).to_not include user

    assert_tracked(current_user.id, "Added User",
      'Invitee'               => user.id,
      'Organization'          => organization.id,
      'Organization Name'     => organization.name,
      'Sent Join Notice'      => true,
      'Sent Personal Message' => false,
    )

    expect(sent_emails).to be_empty
    drain_background_jobs!
    expect(sent_emails.size).to eq 1
    expect( sent_emails.with_subject("You've been added to UCSD Electric Racing").sent_to(email_address) ).to be
  end

end
