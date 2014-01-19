require 'spec_helper'

feature "Viewing conversations and tasks" do

  before { sign_in_as 'amywong.phd@gmail.com' }

  let(:organization){ current_user.organizations.find_by_slug!('sfhealth') }

  scenario %(should render the expected lists of conversations and tasks) do
    goto :my_conversations
    goto :conversations
    expect_listed_conversations_to_eq organization.conversations.my.not_muted
    goto :muted
    expect_listed_conversations_to_eq organization.conversations.my.muted
    goto :all_tasks
    expect_listed_conversations_to_eq organization.tasks.my.all
    goto :my_tasks
    expect_listed_conversations_to_eq organization.tasks.my.doing

    goto :ungrouped_conversations
    goto :conversations
    expect_listed_conversations_to_eq organization.conversations.ungrouped.not_muted
    goto :muted
    expect_listed_conversations_to_eq organization.conversations.ungrouped.muted
    goto :all_tasks
    expect_listed_conversations_to_eq organization.tasks.ungrouped.all
    goto :my_tasks
    expect_listed_conversations_to_eq organization.tasks.ungrouped.doing

    organization.groups.all.each do |group|
      goto group
      goto :conversations
      expect_listed_conversations_to_eq group.conversations.not_muted, group
      goto :muted
      expect_listed_conversations_to_eq  group.conversations.muted, group
      goto :all_tasks
      expect_listed_conversations_to_eq  group.tasks.all, group
      goto :my_tasks
      expect_listed_conversations_to_eq  group.tasks.doing, group
    end
  end

  def goto destination
    case destination
    when :my_conversations
      within_element('the groups pane'){ click_on 'My Conversations' }
    when :ungrouped_conversations
      within_element('the groups pane'){ click_on 'Ungrouped Conversations' }
    when Covered::Group
      within_element('the groups pane'){ click_on "+#{destination.name}" }
    when :conversations
      within_element('the conversations pane'){ click_on 'Conversations' }
    when :muted
      within_element('the conversations pane'){ click_on 'Muted' }
    when :all_tasks
      within_element('the conversations pane'){ click_on 'Tasks'; click_on 'All Tasks' }
    when :my_tasks
      within_element('the conversations pane'){ click_on 'Tasks'; click_on 'My Tasks' }
    else
      raise ArgumentError, "unknown destination #{destination.inspect}"
    end
  end

  def expect_listed_conversations_to_eq conversations, current_group=nil
    serailized_conversations = serailize_conversations(conversations, current_group)
    wait_until_expectation do
      expect(listed_conversations).to eq serailized_conversations
    end
  end

  def listed_conversations
    listed_conversations = evaluate_script <<-JS
      $('.conversations-list li.conversation:visible').map(function(){
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
    listed_conversations.each do |conversation|
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

end