require 'spec_helper'

describe 'model relationships' do
  let(:user) { User.create!(
    email: 'pinky@thebrain.net',
    name: 'Pinky Mouse',
    password: 'password',
  )}

  it "creates a user" do
    user.slug.should == 'pinky-mouse'
    user.projects.count.should == 0
  end

  context "projects" do
    let :project do
      user.projects.create!(
        name: 'Take Over The World!',
        description: 'The same thing we do every night.',
      )
    end

    let(:project_membership) { project.project_memberships.last }

    it "creates a project" do
      user.reload

      project.slug.should == 'take-over-the-world'


      project.users.should == [user]
      user.projects.should == [project]
    end

    it "creates a project membership" do
      project_membership.user.should == User.last
      project_membership.can_write.should be_true
      project_membership.gets_email.should be_true
      project_membership.moderator.should be_false

      project.reload

      project.users.should == [user]
    end

  end

  # def create_a_task!
  #   @task = project.tasks.create!(
  #     name: 'Get money from gameshow'
  #   )
  #   @task.slug.should == 'get-money-from-gameshow'

  #   project.reload

  #   project.tasks.should == [@task]
  # end

  # def create_a_task_doer!
  #   @task.doers.should == []
  #   @task.doers << doer = create(:user)
  #   @task.reload
  #   @task.doers.should == [doer]
  # end

  # def create_a_task_follower!
  #   @task.followers.should == []
  #   @task.followers << follower = create(:user)
  #   @task.reload
  #   @task.followers.should == [follower]
  # end

end
