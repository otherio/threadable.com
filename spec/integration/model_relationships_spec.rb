require 'spec_helper'

describe 'model relationships' do

  let!(:project){ Project.find_by_name('UCSD Electric Racing') }

  def member(email)
    project.members.find_by_email(email) or raise "unable to find #{email}"
  end

  def conversation(subject)
    project.conversations.find_by_subject(subject)
  end

  def task(subject)
    conversation(subject).task
  end

  it "should work" do
    project.should be_a Project

    project.name.should == 'UCSD Electric Racing'
    project.description.should == 'Senior engineering electric race team!'

    project.conversations.to_set.should == Set[
      conversation('Welcome to our new Multify project!'),
      conversation('How are we going to build the body?'),
      conversation('layup body carbon'),
      conversation('install mirrors'),
      conversation('trim body panels'),
      conversation('make wooden form for carbon layup'),
      conversation('get epoxy'),
      conversation('get release agent'),
      conversation('get carbon and fiberglass'),
    ]

    project.members.to_set.should == Set[
      member('alice@ucsd.edu'),
      member('tom@ucsd.edu'),
      member('yan@ucsd.edu'),
      member('bethany@ucsd.edu'),
      member('bob@ucsd.edu'),
    ]

    project.tasks.to_set.should == Set[
      task('layup body carbon'),
      task('install mirrors'),
      task('trim body panels'),
      task('make wooden form for carbon layup'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
    ]

    project.tasks.not_done.to_set.should == Set[
      task('install mirrors'),
      task('trim body panels'),
      task('make wooden form for carbon layup'),
    ]

    project.tasks.done.to_set.should == Set[
      task('layup body carbon'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
    ]

    alice = member('alice@ucsd.edu')
    alice.name.should == 'Alice Neilson'
    alice.email.should == 'alice@ucsd.edu'
    alice.project_memberships.count.should == 1
    alice.projects.should == [project]
    alice.messages.count.should == 3
    alice.conversations.to_set.should == Set[
      conversation('Welcome to our new Multify project!'),
      conversation('How are we going to build the body?'),
      conversation('layup body carbon'),
      conversation('install mirrors'),
      conversation('trim body panels'),
      conversation('make wooden form for carbon layup'),
      conversation('get epoxy'),
      conversation('get release agent'),
      conversation('get carbon and fiberglass'),
    ]
    alice.tasks.should == []

    tom = member('tom@ucsd.edu')
    tom.tasks.to_set.should == Set[
      task('layup body carbon'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
    ]

    conversation = alice.conversations.where(subject: 'Welcome to our new Multify project!').first
    conversation.messages.count.should == 2
    conversation.task.should be_blank
    conversation.project.should == project

    conversation = alice.conversations.where(subject: 'layup body carbon').first
    conversation.messages.count.should == 8
    conversation.task.should be_present
    conversation.project.should == project


    message = conversation.messages.first
    message.conversation.should == conversation
    message.user.should == alice
    message.reply.should be_false

    # conversation.followers.count.should == 0
    # conversation.muters.count.should == 0

    task = conversation.task
    task.project.should == project
    task.conversation.should == conversation
    task.doers.should == [
      member('tom@ucsd.edu'),
      member('yan@ucsd.edu'),
    ]


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
