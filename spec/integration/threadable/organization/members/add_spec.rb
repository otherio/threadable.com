require 'spec_helper'

describe Threadable::Organization::Members::Add do

  let(:organization){ threadable.organizations.find_by_slug! 'raceteam' }

  describe '#call' do
    let(:auto_join_group) { organization.groups.find_by_email_address_tag('graphic-design') }
    let(:non_auto_join_group) { organization.groups.find_by_email_address_tag('electronics') }

    when_signed_in_as 'lcuddy@sfhealth.example.com' do

      context "when given an existing user's email address" do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }
        it 'adds that user to the organization and all auto-joina groups but does not email our group add notices' do
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
        it 'adds that user to the organization and all auto-joina groups but does not email our group add notices' do
          expect{
            organization.members.add(user_id: user.user_id)
          }.to_not change{ User.count }
          expect_organization_member! "amywong.phd@gmail.com"
        end
      end

      context "when given a user object" do
        let(:user) { threadable.users.find_by_email_address('amywong.phd@gmail.com') }
        it 'adds that user to the organization and all auto-joina groups but does not email our group add notices' do
          expect{
            organization.members.add(user: user)
          }.to_not change{ User.count }
          expect_organization_member! "amywong.phd@gmail.com"
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
