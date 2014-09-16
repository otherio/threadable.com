require 'spec_helper'

describe Threadable::Conversation::Scopes, :type => :request do

  let :object do
    Class.new{
      attr_accessor :threadable, :conversations_scope, :tasks_scope
    }.send(:include, described_class).new
  end

  before do
    object.threadable             = threadable
    object.conversations_scope = conversations_scope
    object.tasks_scope         = tasks_scope
  end

  let(:raceteam){ threadable.organizations.find_by_slug! 'raceteam' }
  let(:sfhealth){ threadable.organizations.find_by_slug! 'sfhealth' }

  when_signed_in_as 'bethany@ucsd.example.com' do
    context 'and scope is the raceteam organization' do

      let(:conversations_scope){ raceteam.organization_record.conversations.untrashed }
      let(:tasks_scope)        { raceteam.organization_record.tasks.untrashed         }

      it "returns the expected conversations and tasks" do
        @muted_conversations      = object.muted_conversations(0)
        @not_muted_conversations  = object.not_muted_conversations(0)
        @done_tasks               = object.done_tasks(0)
        @not_done_tasks           = object.not_done_tasks(0)
        @done_doing_tasks         = object.done_doing_tasks(0)
        @not_done_doing_tasks     = object.not_done_doing_tasks(0)


        expect( slugs_for @muted_conversations ).to match_array [
          "layup-body-carbon",
          "get-carbon-and-fiberglass",
          "get-release-agent",
          "get-epoxy",
          "parts-for-the-drive-train",
          "welcome-to-our-threadable-organization",
        ]

        expect( slugs_for @not_muted_conversations ).to match_array [
          "who-wants-to-pick-up-breakfast",
          "who-wants-to-pick-up-dinner",
          "who-wants-to-pick-up-lunch",
          "get-some-4-gauge-wire",
          "get-a-new-soldering-iron",
          "make-wooden-form-for-carbon-layup",
          "trim-body-panels",
          "install-mirrors",
          "how-are-we-paying-for-the-motor-controller",
          "parts-for-the-motor-controller",
          "how-are-we-going-to-build-the-body",
          "drive-trains-are-expensive",
          "inventory-led-supplies",
          "budget-worknight",
          "recruiting",   # access to this is controlled elsewhere.
        ]

        expect( slugs_for @done_tasks ).to match_array [
          "layup-body-carbon",
          "get-epoxy",
          "get-release-agent",
          "get-carbon-and-fiberglass",
        ]

        expect( slugs_for @not_done_tasks ).to match_array [
          "install-mirrors",
          "trim-body-panels",
          "make-wooden-form-for-carbon-layup",
          "get-a-new-soldering-iron",
          "get-some-4-gauge-wire",
          "inventory-led-supplies",
        ]

        expect( slugs_for @done_doing_tasks ).to match_array [

        ]

        expect( slugs_for @not_done_doing_tasks ).to match_array [
          "get-a-new-soldering-iron",
        ]
      end

      context 'scoped to the trash' do
        let(:conversations_scope){ raceteam.organization_record.conversations.trashed }
        let(:tasks_scope)        { raceteam.organization_record.tasks.trashed         }

        it "finds only trashed conversations and tasks" do
          @muted_conversations      = object.muted_conversations(0)
          @not_muted_conversations  = object.not_muted_conversations(0)
          @done_tasks               = object.done_tasks(0)
          @not_done_tasks           = object.not_done_tasks(0)
          @done_doing_tasks         = object.done_doing_tasks(0)
          @not_done_doing_tasks     = object.not_done_doing_tasks(0)

          expect( slugs_for @not_muted_conversations ).to match_array [
            "omg-i-am-so-drunk",
          ]

          expect( slugs_for @muted_conversations ).to match_array []
          expect( slugs_for @done_tasks ).to match_array []
          expect( slugs_for @not_done_tasks ).to match_array []
          expect( slugs_for @done_doing_tasks ).to match_array []
          expect( slugs_for @not_done_doing_tasks ).to match_array []
        end
      end

      context 'scoped to conversations the current user is subscribed to' do

        let(:conversations_scope){ raceteam.organization_record.conversations.for_user(threadable.current_user_id) }

        it "returns the the expected conversations and tasks" do

        end
      end


    end


  end

  def slugs_for collection
    collection.map(&:slug)
  end

end
