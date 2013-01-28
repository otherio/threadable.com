require 'spec_helper'

describe 'model relationships' do


  it "should do all the things" do

    create_a_user!
    create_a_project!
    # create_a_project_membership!
    # create_a_task!
    # create_a_task_doer!
    # create_a_task_follower!

  end

  def create_a_user!
    @user = User.create!(
      email: 'pinky@thebrain.net',
      name: 'Pinky Mouse',
      password: 'password',
    )

    @user.slug.should == 'pinky-mouse'
    @user.projects.count.should == 0
  end

  def create_a_project!
    @project = @user.projects.create!(
      name: 'Take Over The World!',
      description: 'The same thing we do every night.',
    )

    @user.reload

    @project.slug.should == 'take-over-the-world'

    # @project.members.should == [@user]

    @user.projects.should == [@project]

    # @project_membership = @project.project_memberships.create!(
    #   user: create(:user)
    # )
  end

  def create_a_project_membership!
    @project_membership.user.should == User.last
    @project_membership.can_write.should be_true
    @project_membership.gets_email.should be_true
    @project_membership.moderator.should be_false

    @project.reload

    @project.members.should == [@user, @project_membership.user]
  end

  def create_a_task!
    @task = @project.tasks.create!(
      name: 'Get money from gameshow'
    )
    @task.slug.should == 'get-money-from-gameshow'

    @project.reload

    @project.tasks.should == [@task]
  end

  def create_a_task_doer!
    @task.doers.should == []
    @task.doers << doer = create(:user)
    @task.reload
    @task.doers.should == [doer]
  end

  def create_a_task_follower!
    @task.followers.should == []
    @task.followers << follower = create(:user)
    @task.reload
    @task.followers.should == [follower]
  end

end
