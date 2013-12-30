require 'spec_helper'

describe 'model relationships' do

  let!(:organization){ Organization.where(name: "UCSD Electric Racing").first! }

  def member(email)
    organization.members.with_email_address(email).first!
  end

  def conversation(subject)
    organization.conversations.where(subject: subject).first!
  end

  def task(subject)
    organization.tasks.where(subject: subject).first!
  end

  it "should work" do
    organization.should be_a Organization

    organization.name.should == 'UCSD Electric Racing'
    organization.description.should == 'Senior engineering electric race team!'

    organization.conversations.should match_array [
      conversation('Welcome to our Covered organization!'),
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
      conversation('Parts for the motor controller'),
      conversation('How are we paying for the motor controller?'),
    ]

    organization.tasks.should match_array [
      task('layup body carbon'),
      task('install mirrors'),
      task('trim body panels'),
      task('make wooden form for carbon layup'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
    ]

    organization.members.should match_array [
      member('alice@ucsd.example.com'),
      member('tom@ucsd.example.com'),
      member('yan@ucsd.example.com'),
      member('bethany@ucsd.example.com'),
      member('bob@ucsd.example.com'),
      member('jonathan@ucsd.example.com'),
    ]

    organization.tasks.should match_array [
      task('layup body carbon'),
      task('install mirrors'),
      task('trim body panels'),
      task('make wooden form for carbon layup'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
    ]

    organization.tasks.not_done.should match_array [
      task('install mirrors'),
      task('trim body panels'),
      task('make wooden form for carbon layup'),
    ]

    organization.tasks.done.should match_array [
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

    alice = member('alice@ucsd.example.com')
    alice.name.should == 'Alice Neilson'
    alice.email_address.should == 'alice@ucsd.example.com'
    alice.organization_memberships.count.should == 1
    alice.organizations.should == [organization]
    alice.messages.count.should == 3
    alice.conversations.should match_array [
      conversation('Welcome to our Covered organization!'),
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
      conversation('Parts for the motor controller'),
      conversation('How are we paying for the motor controller?'),
    ]
    alice.tasks.should == []

    tom = member('tom@ucsd.example.com')
    tom.tasks.should match_array [
      task('layup body carbon'),
      task('get epoxy'),
      task('get release agent'),
      task('get carbon and fiberglass'),
      task('trim body panels'),
    ]

    conversation = alice.conversations.where(subject: 'Welcome to our Covered organization!').first
    conversation.messages.count.should == 2
    conversation.should_not be_a_task
    conversation.organization.should == organization

    conversation = alice.conversations.where(subject: 'layup body carbon').first
    conversation.messages.count.should == 8
    conversation.should be_a_task
    conversation.organization.should == organization

    message = conversation.messages.first
    message.conversation.should == conversation
    message.creator.should == alice
    message.reply.should be_false
  end

end
