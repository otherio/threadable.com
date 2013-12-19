require 'spec_helper'

describe 'model relationships' do

  let!(:project){ Project.where(name: "UCSD Electric Racing").first! }

  def member(email)
    project.members.with_email_address(email).first!
  end

  def conversation(subject)
    project.conversations.where(subject: subject).first!
  end

  def task(subject)
    project.tasks.where(subject: subject).first!
  end

  it "should work" do
    project.should be_a Project

    project.name.should == 'UCSD Electric Racing'
    project.description.should == 'Senior engineering electric race team!'

    project.conversations.to_set.should == Set[
      conversation('Welcome to our Covered project!'),
      conversation('How are we going to build the body?'),
      conversation('layup body carbon'),
      conversation('install mirrors'),
      conversation('trim body panels'),
      conversation('make wooden form for carbon layup'),
      conversation('get epoxy'),
      conversation('get release agent'),
      conversation('get carbon and fiberglass'),
      conversation('Who wants to pick up lunch?'),
      conversation('Who wants to pick up dinner?'),
      conversation('Who wants to pick up breakfast?'),
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
      member('alice@ucsd.covered.io'),
      member('tom@ucsd.covered.io'),
      member('yan@ucsd.covered.io'),
      member('bethany@ucsd.covered.io'),
      member('bob@ucsd.covered.io'),
      member('jonathan@ucsd.covered.io'),
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

    alice = member('alice@ucsd.covered.io')
    alice.name.should == 'Alice Neilson'
    alice.email_address.should == 'alice@ucsd.covered.io'
    alice.project_memberships.count.should == 1
    alice.projects.should == [project]
    alice.messages.count.should == 3
    alice.conversations.to_set.should == Set[
      conversation('Welcome to our Covered project!'),
      conversation('How are we going to build the body?'),
      conversation('layup body carbon'),
      conversation('install mirrors'),
      conversation('trim body panels'),
      conversation('make wooden form for carbon layup'),
      conversation('get epoxy'),
      conversation('get release agent'),
      conversation('get carbon and fiberglass'),
      conversation('Who wants to pick up lunch?'),
      conversation('Who wants to pick up dinner?'),
      conversation('Who wants to pick up breakfast?'),
    ]
    alice.tasks.should == []

    tom = member('tom@ucsd.covered.io')
    tom.tasks.to_set.should == Set[
      task('layup body carbon'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
      task('trim body panels'),
    ]

    conversation = alice.conversations.where(subject: 'Welcome to our Covered project!').first
    conversation.messages.count.should == 2
    conversation.should_not be_a_task
    conversation.project.should == project

    conversation = alice.conversations.where(subject: 'layup body carbon').first
    conversation.messages.count.should == 8
    conversation.should be_a_task
    conversation.project.should == project

    message = conversation.messages.first
    message.conversation.should == conversation
    message.creator.should == alice
    message.reply.should be_false
  end

end
