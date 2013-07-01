require 'spec_helper'

describe 'model relationships' do

  let!(:project){ Project.find_by_name('UCSD Electric Racing') }

  def member(email)
    project.members.find_by_email(email) or raise "unable to find member #{email}"
  end

  def conversation(subject)
    project.conversations.find_by_subject(subject) or raise "unable to find conversation #{subject}"
  end

  def task(subject)
    project.tasks.find_by_subject(subject) or raise "unable to find task #{subject}"
  end

  it "should work" do
    project.should be_a Project

    project.name.should == 'UCSD Electric Racing'
    project.description.should == 'Senior engineering electric race team!'

    project.conversations.to_set.should == Set[
      conversation('Welcome to our new Covered project!'),
      conversation('How are we going to build the body?'),
      conversation('layup body carbon'),
      conversation('install mirrors'),
      conversation('trim body panels'),
      conversation('make wooden form for carbon layup'),
      conversation('get epoxy'),
      conversation('get release agent'),
      conversation('get carbon and fiberglass'),
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

    project.members.to_set.should == Set[
      member('alice@ucsd.coveredapp.com'),
      member('tom@ucsd.coveredapp.com'),
      member('yan@ucsd.coveredapp.com'),
      member('bethany@ucsd.coveredapp.com'),
      member('bob@ucsd.coveredapp.com'),
      member('jonathan@ucsd.coveredapp.com'),
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

    expect( task('layup body carbon')                 ).to     be_done
    expect( task('install mirrors')                   ).to_not be_done
    expect( task('trim body panels')                  ).to_not be_done
    expect( task('make wooden form for carbon layup') ).to_not be_done
    expect( task('get epoxy')                         ).to     be_done
    expect( task('get release agent')                 ).to     be_done
    expect( task('get carbon and fiberglass')         ).to     be_done

    alice = member('alice@ucsd.coveredapp.com')
    alice.name.should == 'Alice Neilson'
    alice.email.should == 'alice@ucsd.coveredapp.com'
    alice.project_memberships.count.should == 1
    alice.projects.should == [project]
    alice.messages.count.should == 3
    alice.conversations.to_set.should == Set[
      conversation('Welcome to our new Covered project!'),
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

    tom = member('tom@ucsd.coveredapp.com')
    tom.tasks.to_set.should == Set[
      task('layup body carbon'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
      task('trim body panels'),
    ]

    conversation = alice.conversations.where(subject: 'Welcome to our new Covered project!').first
    conversation.messages.count.should == 2
    conversation.should_not be_a_task
    conversation.project.should == project

    conversation = alice.conversations.where(subject: 'layup body carbon').first
    conversation.messages.count.should == 8
    conversation.should be_a_task
    conversation.project.should == project

    message = conversation.messages.first
    message.conversation.should == conversation
    message.user.should == alice
    message.reply.should be_false
  end

end
