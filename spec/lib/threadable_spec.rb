require 'spec_helper'

describe Threadable, :type => :threadable do

  describe 'transactions in test' do
    it 'single transaction' do
      callback1_called = false
      callback2_called = false
      Threadable.transaction do
        Threadable.after_transaction{ callback1_called = true }
        Threadable.after_transaction{ callback2_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
      end
      expect(callback1_called).to be_true
      expect(callback2_called).to be_true
    end
  end

  describe 'transactions', transaction: false do
    before do
      Threadable::Transactions.expect_test_transaction = false
      expect(Threadable.transaction_open?).to be_false
    end

    context 'when another outside transaction is open' do
      # This test is flaky and breaks CI a lot. If you're editing the transaction code,
      # make sure that you uncomment and run it.
      # it 'raises an error' do
      #   ActiveRecord::Base.transaction do
      #     expect{ Threadable.transaction{ } }.to raise_error("another outside transaction is already open")
      #   end
      # end
    end

    context 'when running in a migration' do
      before do
        Threadable::Transactions.expect_test_transaction = true
        Threadable::Transactions.in_migration = true
        expect(Threadable.transaction_open?).to be_false
      end

      it 'does not raise an error' do
        ActiveRecord::Base.transaction do
          expect{ Threadable.transaction{ } }.to_not raise_error
        end
      end

    end

    it 'after_transaction runs the given callback immediately when outside of a transaction' do
      callback_called = false
      Threadable.after_transaction{ callback_called = true }
      expect(callback_called).to be_true
    end

    it 'single transaction' do
      callback1_called = false
      callback2_called = false
      Threadable.transaction do
        Threadable.after_transaction{ callback1_called = true }
        Threadable.after_transaction{ callback2_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
      end
      expect(callback1_called).to be_true
      expect(callback2_called).to be_true
    end

    it 'nested transactions with nested callbacks' do
      callback1_called = false
      callback2_called = false
      Threadable.transaction do
        Threadable.after_transaction{ callback1_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
        Threadable.transaction do
          Threadable.after_transaction{ callback2_called = true }
          expect(callback1_called).to be_false
          expect(callback2_called).to be_false
        end
      end
      expect(callback1_called).to be_true
      expect(callback2_called).to be_true
    end

    it 'nested with inner failure' do
      callback1_called = false
      callback2_called = false
      callback3_called = false
      Threadable.transaction do
        Threadable.after_transaction{ callback1_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
        expect(callback3_called).to be_false
        begin
          Threadable.transaction do
            Threadable.after_transaction{ callback2_called = true }
            Threadable.after_transaction{ callback3_called = true }
            expect(callback1_called).to be_false
            expect(callback2_called).to be_false
            expect(callback3_called).to be_false
            raise "FUUUCK"
          end
        rescue
        end
      end
      expect(callback1_called).to be_true
      expect(callback2_called).to be_false
      expect(callback3_called).to be_false
    end
  end

  it 'can handle nester Threadable.after_transaction block' do
    callback1_called = false
    Threadable.transaction do
      Threadable.after_transaction do
        Threadable.after_transaction do
          callback1_called = true
        end
      end
    end
    expect(callback1_called).to be_true
  end

  def first
    Threadable.transaction do
      Threadable.after_transaction{ @first_after_transaction_called = true }
      second
      return 15
    end
  end

  def second
    Threadable.transaction do
      Threadable.after_transaction{ @second_after_transaction_called = true }
      return 98
    end
  end

  it 'when the transaction block as an explicit return' do
    expect(first).to eq 15
    expect(@first_after_transaction_called).to be_true
    expect(@second_after_transaction_called).to be_true
  end

  describe "autoloads" do

    # # you can use this to generate the list of constants
    #
    #        Rails.application.eager_load!
    #        def deep_constants object
    #          return [] unless object.respond_to?(:constants)
    #          constants = [object]
    #          object.constants(false).each do |name|
    #            child = object.const_get(name, false)
    #            constants += deep_constants child
    #          end
    #          constants
    #        end
    #        deep_constants(Threadable).sort_by(&:name)

    %w{
      Threadable
      Threadable::Application
      Threadable::Attachment
      Threadable::Attachments
      Threadable::Attachments::Create
      Threadable::AuthenticationError
      Threadable::AuthorizationError
      Threadable::Class
      Threadable::Collection
      Threadable::Config
      Threadable::Conversation
      Threadable::Conversation::Creator
      Threadable::Conversation::Events
      Threadable::Conversation::Messages
      Threadable::Conversation::Participant
      Threadable::Conversation::Participants
      Threadable::Conversation::Recipients
      Threadable::Conversations
      Threadable::Conversations::Create
      Threadable::ThreadableError
      Threadable::CurrentUser
      Threadable::CurrentUserNotFound
      Threadable::EmailAddress
      Threadable::EmailAddresses
      Threadable::EmailAddresses::Create
      Threadable::Emails
      Threadable::Emails::InvalidEmail
      Threadable::Emails::Validate
      Threadable::Event
      Threadable::Events
      Threadable::Events::ConversationCreated
      Threadable::Events::Create
      Threadable::Events::TaskAddedDoer
      Threadable::Events::TaskCreated
      Threadable::Events::TaskDone
      Threadable::Events::TaskRemovedDoer
      Threadable::Events::TaskUndone
      Threadable::ExternalServiceError
      Threadable::InMemoryTracker
      Threadable::IncomingEmail
      Threadable::IncomingEmail::Attachments
      Threadable::IncomingEmail::Attachments::Create
      Threadable::IncomingEmail::Bounce
      Threadable::IncomingEmail::Deliver
      Threadable::IncomingEmail::MailgunRequestToEmail
      Threadable::IncomingEmail::Process
      Threadable::IncomingEmails
      Threadable::IncomingEmails::Create
      Threadable::Mailer
      Threadable::Message
      Threadable::Message::Attachments
      Threadable::Message::Body
      Threadable::Message::Body::Empty
      Threadable::Message::Body::HTML
      Threadable::Message::Body::Plain
      Threadable::Messages
      Threadable::Messages::Create
      Threadable::Messages::FindByChildHeader
      Threadable::MixpanelTracker
      Threadable::Model
      Threadable::Organization
      Threadable::Organization::Conversations
      Threadable::Organization::HeldMessage
      Threadable::Organization::HeldMessages
      Threadable::Organization::IncomingEmails
      Threadable::Organization::Member
      Threadable::Organization::Members
      Threadable::Organization::Members::Add
      Threadable::Organization::Members::Remove
      Threadable::Organization::Messages
      Threadable::Organization::Tasks
      Threadable::Organization::Update
      Threadable::Organizations
      Threadable::Organizations::Create
      Threadable::Organizations::Update
      Threadable::RecordInvalid
      Threadable::RecordNotFound
      Threadable::SignUp
      Threadable::Task
      Threadable::Task::Doer
      Threadable::Task::Doers
      Threadable::Tasks
      Threadable::Tasks::Create
      Threadable::Tracker
      Threadable::Transactions
      Threadable::User
      Threadable::User::EmailAddress
      Threadable::User::EmailAddresses
      Threadable::User::Messages
      Threadable::User::Organization
      Threadable::User::Organizations
      Threadable::User::Update
      Threadable::Users
      Threadable::Users::Create
      Threadable::Worker
    }.shuffle.each do |constant_name|

      it "#{constant_name}" do
        expect(constant_name.constantize.name).to eq constant_name
      end

    end

  end

end
