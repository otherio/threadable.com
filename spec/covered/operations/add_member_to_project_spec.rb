# require 'spec_helper'

# describe Covered::Operations::AddMemberToProject do

#   let(:project){ Project.where(name:'Mars Exploration Rover').first! }
#   let(:current_user){ project.members.first! }

#   def member_option
#     {
#       email: 'steve@example.com',
#       name: 'Steve Sampson'
#     }
#   end

#   def options
#     {
#       covered: covered,
#       project: project,
#       member: member_option,
#       message: 'Hey Steve, I added you to our project.'
#     }
#   end

#   def call!
#     described_class.call(options)
#   end

#   let(:user){ User.with_email(member_option[:email]).first! }

#   context "when given an existing user email address" do
#     def member_option
#       {
#         name: 'Bethany Pattern',
#         email: 'bethany@ucsd.covered.io',
#       }
#     end

#     it "should find the existing user and add them to the project" do
#       expect{ call! }.not_to change{ User.count }
#       project.reload
#       expect(project.members).to include user
#       expect(user.projects).to include project
#     end

#   end

#   context "when given a new user email address" do
#     def member_option
#       {
#         name: 'Patten Ozwald',
#         email: 'patten@oswald.me',
#       }
#     end

#     it "should create a new user and add them to the project" do
#       expect{ call! }.to change{ User.count }.by(1)
#       project.reload
#       expect(project.members).to include user
#       expect(user.projects).to include project
#     end

#   end

#   context "when given an invalid email address" do
#     def member_option
#       {
#         name: '234jh32jk4h3j2k4h3kj2h43j2',
#         email: '234o8324hiu23h432',
#       }
#     end

#     it "should raise an ActiveRecord::RecordInvalid error" do
#       expect{ call! }.to raise_error(
#         ActiveRecord::RecordInvalid
#         # 'Validation failed: Email addresses is invalid'
#       )
#     end
#   end

# end
