require 'spec_helper'

describe Covered, :type => :covered do

  describe 'transactions in test' do
    it 'single transaction' do
      callback1_called = false
      callback2_called = false
      Covered.transaction do
        Covered.after_transaction{ callback1_called = true }
        Covered.after_transaction{ callback2_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
      end
      expect(callback1_called).to be_true
      expect(callback2_called).to be_true
    end
  end

  describe 'transactions', transaction: false do
    before do
      Covered::Transactions.expect_test_transaction = false
      expect(Covered.transaction_open?).to be_false
    end

    context 'when another outside transaction is open' do
      it 'raises an error' do
        ActiveRecord::Base.transaction do
          expect{ Covered.transaction{ } }.to raise_error("another outside transaction is already open")
        end
      end
    end

    it 'after_transaction runs the given callback immediately when outside of a transaction' do
      callback_called = false
      Covered.after_transaction{ callback_called = true }
      expect(callback_called).to be_true
    end

    it 'single transaction' do
      callback1_called = false
      callback2_called = false
      Covered.transaction do
        Covered.after_transaction{ callback1_called = true }
        Covered.after_transaction{ callback2_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
      end
      expect(callback1_called).to be_true
      expect(callback2_called).to be_true
    end

    it 'nested transactions with nested callbacks' do
      callback1_called = false
      callback2_called = false
      Covered.transaction do
        Covered.after_transaction{ callback1_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
        Covered.transaction do
          Covered.after_transaction{ callback2_called = true }
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
      Covered.transaction do
        Covered.after_transaction{ callback1_called = true }
        expect(callback1_called).to be_false
        expect(callback2_called).to be_false
        expect(callback3_called).to be_false
        begin
          Covered.transaction do
            Covered.after_transaction{ callback2_called = true }
            Covered.after_transaction{ callback3_called = true }
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

  def first
    Covered.transaction do
      Covered.after_transaction{ @first_after_transaction_called = true }
      second
      return 15
    end
  end

  def second
    Covered.transaction do
      Covered.after_transaction{ @second_after_transaction_called = true }
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
      Covered::Collection
      Covered::Config
      Covered::Conversation
      Covered::Conversation::Creator
      Covered::Conversation::Events
      Covered::Conversation::Messages
      Covered::Conversation::Participant
      Covered::Conversation::Participants
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
      Covered::Emails::InvalidEmail
      Covered::Emails::Validate
      Covered::Event
      Covered::Events
      Covered::Events::ConversationCreated
      Covered::Events::Create
      Covered::Events::TaskAddedDoer
      Covered::Events::TaskCreated
      Covered::Events::TaskDone
      Covered::Events::TaskRemovedDoer
      Covered::Events::TaskUndone
      Covered::InMemoryTracker
      Covered::IncomingEmail
      Covered::IncomingEmail::Attachments
      Covered::IncomingEmail::Attachments::Create
      Covered::IncomingEmail::Bounce
      Covered::IncomingEmail::Deliver
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
      Covered::Model
      Covered::Organization
      Covered::Organization::Conversations
      Covered::Organization::HeldMessage
      Covered::Organization::HeldMessages
      Covered::Organization::IncomingEmails
      Covered::Organization::Member
      Covered::Organization::Members
      Covered::Organization::Members::Add
      Covered::Organization::Members::Remove
      Covered::Organization::Messages
      Covered::Organization::Tasks
      Covered::Organization::Update
      Covered::Organizations
      Covered::Organizations::Create
      Covered::Organizations::Update
      Covered::RecordInvalid
      Covered::RecordNotFound
      Covered::SignUp
      Covered::Task
      Covered::Task::Doer
      Covered::Task::Doers
      Covered::Tasks
      Covered::Tasks::Create
      Covered::Tracker
      Covered::Transactions
      Covered::User
      Covered::User::EmailAddress
      Covered::User::EmailAddresses
      Covered::User::Messages
      Covered::User::Organization
      Covered::User::Organizations
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
