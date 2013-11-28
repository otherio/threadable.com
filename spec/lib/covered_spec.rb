require 'spec_helper'

describe Covered, :type => :covered do

  # it 'integration' do
  #   expect{ Covered.new }.to raise_error ArgumentError, 'required options: :host'

  #   covered = Covered.new(host: 'covered.io')
  #   expect(covered.host).to eq 'covered.io'
  #   expect(covered.port).to eq 80
  #   expect(covered.current_user).to be_nil

  #   laura = Factories.create(:user, email_address: 'laura@me.com')

  #   covered = Covered.new(host: 'covered.io', current_user_id: laura.id)
  #   expect(covered.host).to eq 'covered.io'
  #   expect(covered.port).to eq 80
  #   expect(covered.current_user).to_not be_nil

  #   expect(covered.current_user.id             ).to eq laura.id
  #   expect(covered.current_user.to_param       ).to eq laura.to_param
  #   expect(covered.current_user.name           ).to eq laura.name
  #   expect(covered.current_user.email_address  ).to eq laura.email_address
  #   expect(covered.current_user.slug           ).to eq laura.slug
  #   expect(covered.current_user.avatar_url     ).to eq laura.avatar_url

  #   expect(covered.current_user.projects.all.map(&:name)).to eq []

  #   project = covered.current_user.projects.create(
  #     name: 'Make a space duck',
  #     short_name: 'Space Duck',
  #   )

  #   expect(project).to be_persisted
  #   expect(project.name).to eq 'Make a space duck'
  #   expect(project.short_name).to eq 'Space Duck'

  #   expect(project.members).to include covered.current_user

  #   expect(covered.current_user.projects.all.map(&:name)).to eq ['Make a space duck']

  #   ian = project.members.add(name: 'Ian Baker', email_address: 'ian@other.io')

  #   expect(project.members).to include ian
  #   expect(project.members.all).to include ian

  #   expect( covered.current_user.projects.find_by_name("Make a space duck") ).to eq project
  #   expect( covered.current_user.projects.find_by_slug("space-duck") ).to eq project

  #   # reload
  #   project = covered.current_user.projects.find_by_slug("space-duck")

  #   expect(project.members).to include covered.current_user
  #   expect(project.members).to include ian

  #   expect(project.members.all).to_not include covered.current_user
  #   expect(project.members.all).to include ian
  # end

  describe "autoloading constants" do

    # # you can use this to generate the list of constants
    #
    #        def deep_constants object
    #          return [] unless object.respond_to?(:constants)
    #          constants = [object]
    #          object.constants(false).each do |name|
    #            child = object.const_get(name, false)
    #            constants += deep_constants child
    #          end
    #          constants
    #        end
    #        deep_constants Covered

    %w{
      Covered
      Covered::CoveredError
      Covered::RecordNotFound
      Covered::RecordInvalid
      Covered::CurrentUserNotFound
      Covered::AuthorizationError
      Covered::UserAlreadyAMemberOfProjectError
      Covered::CurrentUser
      Covered::Users
      Covered::User
      Covered::User::EmailAddresses
      Covered::User::EmailAddress
      Covered::User::Projects
      Covered::User::Messages
      Covered::Projects
      Covered::Projects::Create
      Covered::Project
      Covered::Project::Members
      Covered::Project::Member
      Covered::Project::Conversations
      Covered::Project::Conversations::Create
      Covered::Project::Conversations::Create::OPTIONS
      Covered::Project::Conversation
      Covered::Project::Conversation::Creator
      Covered::Project::Conversation::Events
      Covered::Project::Conversation::Event
      Covered::Project::Conversation::CreatedEvent
      Covered::Project::Conversation::Messages
      Covered::Project::Conversation::Messages::Create
      Covered::Project::Conversation::Messages::Create::OPTIONS
      Covered::Project::Conversation::Message
      Covered::Project::Conversation::Message::Attachments
      Covered::Project::Conversation::Message::Attachment
      Covered::Project::Conversation::Message::Body
      Covered::Project::Conversation::Message::Body::HTML
      Covered::Project::Conversation::Message::Body::Plain
      Covered::Project::Conversation::Recipients
      Covered::Project::Conversation::Recipient
      Covered::Project::Conversation::Participants
      Covered::Project::Conversation::Participant
      Covered::Project::Tasks
      Covered::Project::Tasks::Create
      Covered::Project::Task
      Covered::Project::Task::Event
      Covered::Project::Task::CreatedEvent
      Covered::Project::Task::DoneEvent
      Covered::Project::Task::UndoneEvent
      Covered::Project::Task::AddedDoerEvent
      Covered::Project::Task::RemovedDoerEvent
      Covered::Project::Task::Doers
      Covered::Emails
      Covered::Mailer
      Covered::Worker
      Covered::ProcessIncomingEmail
      Covered::ProcessIncomingEmail::CreateConversationMessage
      Covered::SignUp
      Covered::SignUp::OPTIONS
      Covered::Application
      Covered::Config
      Covered::Class
    }.shuffle.each do |constant_name|

      it "#{constant_name}" do
        expect(constant_name.constantize.name).to eq constant_name
      end

    end

  end

end
