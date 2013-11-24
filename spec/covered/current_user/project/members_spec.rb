require 'spec_helper'

describe Covered::CurrentUser::Project::Members do

  let(:project_record){ Factories.create(:project) }
  let(:covered_current_user_record){ Factories.create(:user) }
  before{ project_record.members << covered_current_user_record }
  let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
  let(:members){ project.members }
  subject{ members }

  its(:covered){ should eq covered }
  its(:project){ should eq project }
  its(:inspect){ should eq %(#<Covered::CurrentUser::Project::Members project_id: #{project.id.inspect}>) }


  its(:all){
    all_members = project_record.reload.memberships.map{|project_membership_record|
      Covered::CurrentUser::Project::Member.new(project, project_membership_record)
    }
    should eq all_members
  }

  describe 'add' do

    context 'when given a hash' do
      context 'with an email address of an existing user' do
        it 'should find that user and add them to the project' do
          user_record = Factories.create(:user)

          member = nil
          expect{
            member = members.add(name: 'ignored', email_address: user_record.email_address)
          }.to_not change{ User.count }

          expect(member.name         ).to eq user_record.name
          expect(member.email_address).to eq user_record.email_address
          expect(project_record.members).to include user_record
        end
      end
      context 'with a new email address' do
        it 'should create a new user and add them to the project' do
          member = nil
          expect{
            member = members.add(name: 'Bob Saget', email_address: 'bob@sagetup.org')
          }.to change{ User.count }.by(1)

          user_record = User.last!
          expect(user_record.name         ).to eq 'Bob Saget'
          expect(user_record.email_address).to eq 'bob@sagetup.org'
          expect(project_record.members).to include user_record
        end
      end
    end

    context 'when given a user' do
      it 'should add that user to the project' do
        user = Covered::User.new(covered, Factories.create(:user))
        member = nil
        expect{ member = members.add(user) }.to_not change{ User.count }
        expect(member.user_id).to eq user.id
        expect(project_record.members).to include user.user_record
      end
    end

  end

  describe 'include?' do
    it "should return true if the given member is a member" do
      project_record.members.count.should > 0
      project_record.members.each do |user_record|
        user = Covered::User.new(covered, user_record)
        expect(members.include?(user)).to be_true
      end
      user = Covered::User.new(covered, Factories.create(:user))
      expect(members.include?(user)).to be_false
    end
  end

  # its(:build){ should be_a Covered::CurrentUser::Project::Conversation }
  # its(:new  ){ should be_a Covered::CurrentUser::Project::Conversation }

  # context 'build(type:"Task")' do
  #   subject{ conversations.build(type:"Task") }
  #   it{ should be_a Covered::CurrentUser::Project::Task }
  #   its(:project){ should eq project }
  # end

  # its(:all){ should eq [] }
  # context "when there are conversations" do
  #   before do
  #     @conversation_records = 2.times.map{
  #       conversation_record = Factories.create(:conversation, project: project_record)
  #       Covered::CurrentUser::Project::Conversation.new(project, conversation_record)
  #     }
  #   end
  #   its(:all){ should =~ @conversation_records }

  #   describe "find_by_slug" do
  #     subject{ conversations.find_by_slug(@conversation_records.first.slug) }
  #     it{ should eq @conversation_records.first }
  #   end
  # end
end
