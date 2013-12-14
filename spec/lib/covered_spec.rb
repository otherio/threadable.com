require 'spec_helper'

describe Covered, :type => :covered do

  describe 'transaction', transaction: false do
    it 'should save changes to postgres and redis at the same time' do
      expect(Covered.redis.client).to be_a Redis::Client
      expect(Covered.postgres.transaction_open?).to be_false
      Covered.transaction do
        expect(Covered.redis.client).to be_a Redis::Pipeline::Multi
        expect(Covered.postgres.transaction_open?).to be_true
      end
      expect(Covered.redis.client).to be_a Redis::Client
      expect(Covered.postgres.transaction_open?).to be_false
    end
  end

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
      Covered::Application
      Covered::Attachment
      Covered::Attachments
      Covered::Attachments::Create
      Covered::AuthenticationError
      Covered::AuthorizationError
      Covered::Class
      Covered::Config
      Covered::Conversation
      Covered::Conversation::CreatedEvent
      Covered::Conversation::Creator
      Covered::Conversation::Event
      Covered::Conversation::Events
      Covered::Conversation::Messages
      Covered::Conversation::Participant
      Covered::Conversation::Participants
      Covered::Conversation::Recipient
      Covered::Conversation::Recipients
      Covered::Conversations
      Covered::Conversations::Create
      Covered::CoveredError
      Covered::CurrentUser
      Covered::CurrentUserNotFound
      Covered::EmailAddress
      Covered::EmailAddresses
      Covered::EmailAddresses::Create
      Covered::Emails
      Covered::Event
      Covered::Events
      Covered::InMemoryTracker
      Covered::IncomingEmail
      Covered::IncomingEmail::Attachments
      Covered::IncomingEmail::Attachments::Create
      Covered::IncomingEmail::Creator
      Covered::IncomingEmail::MailgunRequestToEmail
      Covered::IncomingEmail::Process
      Covered::IncomingEmails
      Covered::IncomingEmails::Create
      Covered::Mailer
      Covered::Message
      Covered::Message::Attachments
      Covered::Message::Body
      Covered::Message::Body::Empty
      Covered::Message::Body::HTML
      Covered::Message::Body::Plain
      Covered::Messages
      Covered::Messages::Create
      Covered::Messages::FindByChildHeader
      Covered::MixpanelTracker
      Covered::Project
      Covered::Project::Conversations
      Covered::Project::Member
      Covered::Project::Members
      Covered::Project::Members::Add
      Covered::Project::Members::Remove
      Covered::Project::Messages
      Covered::Project::Tasks
      Covered::Project::Update
      Covered::Projects
      Covered::Projects::Create
      Covered::RecordInvalid
      Covered::RecordNotFound
      Covered::SignUp
      Covered::Task
      Covered::Task::AddedDoerEvent
      Covered::Task::CreatedEvent
      Covered::Task::Doers
      Covered::Task::DoneEvent
      Covered::Task::Event
      Covered::Task::RemovedDoerEvent
      Covered::Task::UndoneEvent
      Covered::Tasks
      Covered::Tasks::Create
      Covered::Tracker
      Covered::User
      Covered::User::EmailAddress
      Covered::User::EmailAddresses
      Covered::User::Messages
      Covered::User::Project
      Covered::User::Projects
      Covered::User::Update
      Covered::Users
      Covered::Users::Create
      Covered::Worker
    }.shuffle.each do |constant_name|

      it "#{constant_name}" do
        expect(constant_name.constantize.name).to eq constant_name
      end

    end

  end

end
