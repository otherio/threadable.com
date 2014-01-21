require 'spec_helper'

describe 'getting conversations' do

  # organization.       my.    muted_conversations
  # organization.       my.not_muted_conversations
  # organization.       my.    done_doing_tasks
  # organization.       my.not_done_doing_tasks
  # organization.       my.    done_not_doing_task
  # organization.       my.not_done_not_doing_task
  # organization.ungrouped.    muted_conversations
  # organization.ungrouped.not_muted_conversations
  # organization.ungrouped.    done_doing_tasks
  # organization.ungrouped.not_done_doing_tasks
  # organization.ungrouped.    done_not_doing_task
  # organization.ungrouped.not_done_not_doing_task
  # group.                     muted_conversations
  # group.                 not_muted_conversations
  # group.                     done_doing_tasks
  # group.                 not_done_doing_tasks
  # group.                     done_not_doing_task
  # group.                 not_done_not_doing_task

  when_signed_in_as 'bethany@ucsd.example.com' do

    let(:organization){ covered.organizations.find_by_slug! 'raceteam' }

    it 'works as expected' do
          @muted_conversations = organization.    muted_conversations
      @not_muted_conversations = organization.not_muted_conversations
          @done_tasks          = organization.    done_tasks
      @not_done_tasks          = organization.not_done_tasks
          @done_doing_tasks    = organization.    done_doing_tasks
      @not_done_doing_tasks    = organization.not_done_doing_tasks

      check_consistancy!

      # my

          @muted_conversations = organization.my.    muted_conversations
      @not_muted_conversations = organization.my.not_muted_conversations
          @done_tasks          = organization.my.    done_tasks
      @not_done_tasks          = organization.my.not_done_tasks
          @done_doing_tasks    = organization.my.    done_doing_tasks
      @not_done_doing_tasks    = organization.my.not_done_doing_tasks

      check_consistancy!

      all.each do |conversation|
        conversation.groups.empty? || (conversation.groups.all & my_groups).present? or fail("#{conversation.inspect} is not mine.")
      end

      # ungrouped

          @muted_conversations = organization.ungrouped.    muted_conversations
      @not_muted_conversations = organization.ungrouped.not_muted_conversations
          @done_tasks          = organization.ungrouped.    done_tasks
      @not_done_tasks          = organization.ungrouped.not_done_tasks
          @done_doing_tasks    = organization.ungrouped.    done_doing_tasks
      @not_done_doing_tasks    = organization.ungrouped.not_done_doing_tasks

      check_consistancy!

      all.each do |conversation|
        expect(conversation.groups).to be_empty
      end

      # for each group

      organization.groups.all.each do |group|

            @muted_conversations = group.    muted_conversations
        @not_muted_conversations = group.not_muted_conversations
            @done_tasks          = group.    done_tasks
        @not_done_tasks          = group.not_done_tasks
            @done_doing_tasks    = group.    done_doing_tasks
        @not_done_doing_tasks    = group.not_done_doing_tasks
        check_consistancy!

        all.each do |conversation|
          expect(conversation.groups).to include group
        end

      end

    end



    def check_consistancy!
      expect(@muted_conversations  & @not_muted_conversations).to eq []
      expect(@done_tasks           & @not_done_tasks         ).to eq []
      expect(@done_doing_tasks     & @not_done_doing_tasks   ).to eq []

          @muted_conversations.each{|conversation| expect(conversation).to     be_muted }
      @not_muted_conversations.each{|conversation| expect(conversation).to_not be_muted }

          @done_tasks      .each{|task| expect(task).to     be_done }
      @not_done_tasks      .each{|task| expect(task).to_not be_done }
          @done_doing_tasks.each{|task| expect(task).to     be_done }
      @not_done_doing_tasks.each{|task| expect(task).to_not be_done }

          @done_doing_tasks.each{|task| expect(task).to be_being_done_by current_user }
      @not_done_doing_tasks.each{|task| expect(task).to be_being_done_by current_user }
    end

    def my_groups
      @my_groups ||= organization.groups.my.freeze
    end

    def all
          @muted_conversations +
      @not_muted_conversations +
          @done_tasks          +
      @not_done_tasks          +
          @done_doing_tasks    +
      @not_done_doing_tasks
    end
  end

end
