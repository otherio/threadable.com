# require 'spec_helper'

# describe Covered::CurrentUser::Project::Messages do

#   let(:project_record){ Factories.create(:project) }
#   let(:covered_current_user_record){ Factories.create(:user) }
#   before{ project_record.members << covered_current_user_record }
#   let(:project){ Covered::CurrentUser::Project.new(current_user, project_record) }
#   let(:messages){ project.messages }
#   subject{ messages }

#   its(:covered){ should eq covered }
#   its(:project){ should eq project }
#   its(:inspect){ should eq %(#<Covered::CurrentUser::Project::Messages project_id: #{project.id.inspect}>) }

#   its(:all){ should eq [] }
#   context "when there are messages" do
#     before do
#       conversation_record = Factories.create(:conversation, project: project_record)
#       message_records = 2.times.map{
#         Factories.create(:message, conversation: conversation_record)
#       }
#     end
#     its(:all){ should eq [] }
#   end

# end
