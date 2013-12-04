require 'spec_helper'

describe Covered, :type => :covered do

  describe "autoloads" do

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
    #        deep_constants(Covered).sort_by(&:name)

    %w{
      Covered
      Covered::CoveredError
      Covered::RecordNotFound
      Covered::RecordInvalid
      Covered::CurrentUserNotFound
      Covered::AuthorizationError
      Covered::AuthenticationError
      Covered::Config
      Covered::Class
      Covered::CurrentUser
      Covered::Tracker
      Covered::InMemoryTracker
      Covered::MixpanelTracker
      Covered::Emails
      Covered::EmailAddresses
      Covered::EmailAddresses::Create
      Covered::EmailAddress
      Covered::Users
      Covered::Users::Create
      Covered::User
      Covered::User::EmailAddresses
      Covered::User::EmailAddress
      Covered::User::Projects
      Covered::User::Messages
      Covered::User::Update
      Covered::Projects
      Covered::Projects::Create
      Covered::Project
      Covered::Project::Update
      Covered::Project::Members
      Covered::Project::Members::Add
      Covered::Project::Members::Remove
      Covered::Project::Member
      Covered::Project::Conversations
      Covered::Project::Messages
      Covered::Project::Tasks
      Covered::Conversations
      Covered::Conversations::Create
      Covered::Conversation
      Covered::Conversation::Creator
      Covered::Conversation::Events
      Covered::Conversation::Event
      Covered::Conversation::CreatedEvent
      Covered::Conversation::Messages
      Covered::Conversation::Recipients
      Covered::Conversation::Recipient
      Covered::Conversation::Participants
      Covered::Conversation::Participant
      Covered::Tasks
      Covered::Tasks::Create
      Covered::Task
      Covered::Task::Event
      Covered::Task::CreatedEvent
      Covered::Task::DoneEvent
      Covered::Task::UndoneEvent
      Covered::Task::AddedDoerEvent
      Covered::Task::RemovedDoerEvent
      Covered::Task::Doers
      Covered::Messages
      Covered::Messages::Create
      Covered::Messages::FindByChildHeader
      Covered::Message
      Covered::Message::Attachments
      Covered::Message::Body
      Covered::Message::Body::HTML
      Covered::Message::Body::Plain
      Covered::Attachments
      Covered::Attachments::Create
      Covered::Attachment
      Covered::IncomingEmails
      Covered::IncomingEmails::Create
      Covered::IncomingEmail
      Covered::IncomingEmail::Creator
      Covered::IncomingEmail::Attachments
      Covered::IncomingEmail::MailgunRequestToEmail
      Covered::Mailer
      Covered::Worker
      Covered::ProcessIncomingEmail
      Covered::ProcessIncomingEmail::CreateConversationMessage
      Covered::SignUp
      Covered::Application
    }.shuffle.each do |constant_name|

      it "#{constant_name}" do
        expect(constant_name.constantize.name).to eq constant_name
      end

    end

  end

end
