require 'spec_helper'

describe 'model relationships' do

  it "should work" do
    project = Project.find_by_name('UCSD Electric Racingz')
    project.should be_a Project

    project.conversations.count.should == 11
    project.tasks.count.should == 10
    project.project_memberships.count.should == 5
    project.users.count.should == 5

    alice = project.users.where(name: 'Alice Neilson').first

    alice.project_memberships.count.should == 1
    alice.projects.count.should == 1
    alice.projects.should == [project]
    alice.messages.count.should == 2
    alice.conversations.count.should == 1
    alice.tasks.count.should == 2

    message = alice.messages.first
    conversation = alice.conversations.first


    message.conversation.should == conversation
    message.user.should == alice

    conversation.messages.count.should == 8
    conversation.task.should be_present
    conversation.project.should == project
    # conversation.followers.count.should == 0
    # conversation.muters.count.should == 0

    task = conversation.task
    task.project.should == project
    task.conversation.should == conversation
    task.doers.count.should == 0


  end

  # let(:user) { User.create!(
  #   email: 'pinky@thebrain.net',
  #   name: 'Pinky Mouse',
  #   password: 'password',
  # )}

  # it "creates a user" do
  #   user.slug.should == 'pinky-mouse'
  #   user.projects.count.should == 0
  # end

  # context "projects" do
  #   let :project do
  #     user.projects.create!(
  #       name: 'Take Over The World!',
  #       description: 'The same thing we do every night.',
  #     )
  #   end

  #   let(:project_membership) { project.project_memberships.last }

  #   it "creates a project" do
  #     user.reload

  #     project.slug.should == 'take-over-the-world'


  #     project.users.should == [user]
  #     user.projects.should == [project]
  #   end

  #   it "creates a project membership" do
  #     project_membership.user.should == User.last
  #     project_membership.can_write.should be_true
  #     project_membership.gets_email.should be_true
  #     project_membership.moderator.should be_false

  #     project.reload

  #     project.users.should == [user]
  #   end

  # end

  # # def create_a_task!
  # #   @task = project.tasks.create!(
  # #     name: 'Get money from gameshow'
  # #   )
  # #   @task.slug.should == 'get-money-from-gameshow'

  # #   project.reload

  # #   project.tasks.should == [@task]
  # # end

  # # def create_a_task_doer!
  # #   @task.doers.should == []
  # #   @task.doers << doer = create(:user)
  # #   @task.reload
  # #   @task.doers.should == [doer]
  # # end

  # # def create_a_task_follower!
  # #   @task.followers.should == []
  # #   @task.followers << follower = create(:user)
  # #   @task.reload
  # #   @task.followers.should == [follower]
  # # end

end
