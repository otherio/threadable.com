require 'spec_helper'

feature "Viewing conversations" do

  before { sign_in_as 'amywong.phd@gmail.com' }

  let(:organization){ current_user.organizations.find_by_slug!('sfhealth') }

  context 'confirming conversations are listed with the correct information' do

    scenario %(In "My Conversations", "Ungrouped Conversations", and all "Group Conversations" sections) do
      expect(page).to be_at my_conversations_url(organization)
      expect(conversations).to eq my_conversations

      within_element 'the groups pane' do
        click_on "Ungrouped Conversations"
      end
      expect(page).to be_at ungrouped_conversations_url(organization)
      expect(conversations).to eq ungrouped_conversations

      organization.groups.all.each do |group|
        within_element 'the groups pane' do
          click_on "+#{group.name}"
        end
        expect(page).to be_at group_conversations_url(organization, group)
        expect(conversations).to eq group_conversations(group)
      end
    end

    def conversations
      conversations = evaluate_script <<-JS
        $('.conversations-list .all-conversations .conversation:visible').map(function(){
            var
              conversation       = $(this),
              icon               = conversation.find('.icon i'),
              task               = (icon.is('.uk-icon-comment-o') ? false : icon.is('.uk-icon-check') ? true : null),
              participant_names  = conversation.find('.participant-names').text(),
              number_of_messages = conversation.find('.number-of-messages').text(),
              subject            = conversation.find('.subject').text(),
              message_summary    = conversation.find('.message-summary').text(),
              groups             = conversation.find('.groups .badge').map(function(){ return $(this).text(); }).get();

          return {
            task:               task,
            participant_names:  participant_names,
            number_of_messages: number_of_messages,
            subject:            subject,
            message_summary:    message_summary,
            groups:             groups
          };
        }).get();
      JS
      conversations.each do |conversation|
        conversation['message_summary'].strip!
        conversation['number_of_messages'] = conversation['number_of_messages'][1..-2].to_i
        conversation['groups'] = conversation['groups'].to_set
      end
    end

    def serailize_conversations conversations, current_group=nil
      conversations.map do |conversation|
        message_summary = conversation.messages.latest.try(:body_plain).try(:[], 0..50) || "no messages"
        message_summary = message_summary.gsub("\n", ' ').strip
        groups = conversation.groups.all.map do |group|
          "+#{group.name}" if group != current_group
        end.compact.to_set
        {
          'task'               => conversation.task?,
          'participant_names'  => conversation.participant_names.join(', '),
          'number_of_messages' => conversation.messages.count,
          'subject'            => conversation.subject,
          'message_summary'    => message_summary,
          'groups'             => groups,
        }
      end
    end

    def my_conversations
      serailize_conversations organization.conversations.my
    end

    def ungrouped_conversations
      serailize_conversations organization.conversations.ungrouped
    end

    def group_conversations group
      serailize_conversations group.conversations.all, group
    end
  end



  context 'confirming conversations are listed and filtered correctly' do

    scenario %(viewing tasks) do
      begin
      # expect(page).to be_at my_conversations_url(organization)


      click_on 'My Conversations'
      within '.conversations-list' do
        click_on 'Conversations'
        expect(visible_conversations_subjects).to eq all_conversations_for(:my_conversations).map(&:subject)

        click_on 'Tasks'

        click_on 'My Tasks'
        expect(visible_conversations_subjects).to eq my_undone_tasks_for(:my_conversations).map(&:subject)

        click_on 'Show Done'
        expect(visible_conversations_subjects).to eq my_tasks_for(:my_conversations).map(&:subject)

        click_on 'All Tasks'
        expect(visible_conversations_subjects).to eq all_tasks_for(:my_conversations).map(&:subject)

        click_on 'Hide Done'
        expect(visible_conversations_subjects).to eq all_undone_tasks_for(:my_conversations).map(&:subject)
      end
    rescue
      puts $!.backtrace.first(10)
      raise
    end
    end

    def conversations_for target
      @cache ||= {}
      @cache[target] ||= case target
      when :my_conversations;        organization.conversations.my
      when :ungrouped_conversations; organization.conversations.ungrouped
      when Covered::Group;           target.conversation.all
      end
    end

    def all_conversations_for target
      conversations_for(target).sort_by(&:updated_at).reverse
    end
    def all_tasks_for target
      all_conversations_for(target).select(&:task?).sort_by do |task|
        [(task.done? ? 1 : 0), task.updated_at]
      end.reverse
    end
    def my_tasks_for target
      all_tasks_for(target).select{|t| t.doers.include? current_user }
    end


    def my_undone_tasks_for target
      my_tasks_for(target).reject(&:done?)
    end
    def my_done_tasks_for target
      my_tasks_for(target).select(&:done?)
    end

    def all_undone_tasks_for target
      all_tasks_for(target).reject(&:done?)
    end
    def all_done_tasks_for target
      all_tasks_for(target).select(&:done?)
    end


    def visible_conversations_subjects
      evaluate_script <<-JS
        $('li.conversation:visible').map(function(){
          return $(this).find('.subject').text();
        }).get();
      JS
    end


    # def visible_conversations_subjects
    #   get_subjects_for_selector '.conversations-list .all-conversations .conversation:visible'
    # end

    # def visible_tasks_subjects
    #   get_subjects_for_selector '.conversations-list .all-conversations .task:visible'
    # end

    # def visible_done_tasks_subjects
    #   get_subjects_for_selector '.conversations-list .done-tasks .task:visible'
    # end

    # def get_subjects_for_selector selector
    #   evaluate_script <<-JS
    #     $(#{selector.inspect}).map(function(){ return $(this).find('.subject').text(); }).get();
    #   JS
    # end



    # let(:my_conversations_subjects)       { map_to_subjects           organization.conversations.my }
    # let(:my_my_tasks_subjects)            { map_to_all_tasks_subjects organization.conversations.my }
    # let(:my_all_tasks_subjects)           { map_to_my_tasks_subjects  organization.conversations.my }
    # let(:ungrouped_conversations_subjects){ map_to_subjects           organization.conversations.ungrouped }
    # let(:ungrouped_my_tasks_subjects)     { map_to_all_tasks_subjects organization.conversations.ungrouped }
    # let(:ungrouped_all_taks_subjects)     { map_to_my_tasks_subjects  organization.conversations.ungrouped }


    # # filters
    # def map_to_subjects conversations
    #   conversations.map(&:subject)
    # end
    # def map_to_all_tasks_subjects conversations
    #   conversations.select(&:task?).map(&:subject)
    # end
    # def map_to_my_tasks_subjects conversations
    #   conversations.select(&:task?).map{|t| t.doers.include? current_user }.map(&:subject)
    # end

  end

end
