require 'spec_helper'

feature "Viewing conversations and tasks" do

  before {
    sign_in_as 'amywong.phd@gmail.com'
    resize_window_to :large
  }

  let(:organization){ current_user.organizations.find_by_slug!('sfhealth') }

  scenario %(should render the expected lists of conversations and tasks) do
    goto :my_conversations
    goto :conversations
    expect_listed_conversations_to_eq organization.my.not_muted_conversations(0)
    goto :muted
    expect_listed_conversations_to_eq organization.my.muted_conversations(0)
    goto :all_tasks
    expect_listed_tasks_to_eq organization.my.not_done_tasks(0)
    goto :my_tasks
    expect_listed_tasks_to_eq organization.my.not_done_doing_tasks(0)

    organization.groups.all.each do |group|
      goto group
      goto :conversations
      expect_listed_conversations_to_eq group.not_muted_conversations(0), group
      goto :muted
      expect_listed_conversations_to_eq group.muted_conversations(0), group
      goto :all_tasks
      expect_listed_tasks_to_eq group.not_done_tasks(0), group
      goto :my_tasks
      expect_listed_tasks_to_eq group.not_done_doing_tasks(0), group
    end
  end

  def goto destination
    case destination
    when :my_conversations
      within_element('the sidebar'){ click_on 'My Conversations' }
    when Threadable::Group
      if destination.members.all.map(&:id).include? current_user.id
        within_element('my groups'){ click_on "#{destination.name}" }
      else
        within_element('other groups'){ click_on "#{destination.name}" }
      end
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
    serialized_conversations = serialize_conversations(conversations, current_group)
    wait_until_expectation do
      # don't check order, since these get reordered in the ember app sometimes.
      expect(listed_conversations).to eq serialized_conversations
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
      conversation['subject'].strip!
      conversation['message_summary'].strip!
      conversation['number_of_messages'] = conversation['number_of_messages'][1..-2].to_i
      conversation['groups'] = conversation['groups'].to_set
    end
  end

  def serialize_conversations conversations, current_group=nil
    conversations.map do |conversation|
      message_summary = conversation.messages.latest.try(:body_plain).try(:[], 0..50) || "no messages"
      message_summary = message_summary.gsub("\n", ' ').strip
      {
        'task'               => conversation.task?,
        'participant_names'  => conversation.participant_names.join(', '),
        'number_of_messages' => conversation.messages.count,
        'subject'            => conversation.subject,
        'message_summary'    => message_summary,
        'groups'             => groups_for(conversation, current_group),
      }
    end
  end


  def expect_listed_tasks_to_eq tasks, current_group=nil
    serialized_tasks = serialize_tasks(tasks, current_group)
    wait_until_expectation do
      expect(listed_tasks).to eq serialized_tasks
    end
  end


  def listed_tasks
    listed_tasks = evaluate_script <<-JS
      $('.tasks-list li.task:visible').map(function(){
          var
            task    = $(this),
            subject = task.find('.subject').text(),
            groups  = task.find('.groups .badge').map(function(){ return $(this).text(); }).get();

        return {
          subject: subject,
          groups:  groups
        };
      }).get();
    JS
    listed_tasks.each do |task|
      task['subject'].strip!
      task['groups'] = task['groups'].to_set
    end
  end

  def serialize_tasks tasks, current_group=nil
    tasks.map do |task|
      {
        'subject' => task.subject,
        'groups'  => groups_for(task, current_group),
      }
    end
  end

  def groups_for conversation, current_group
    groups = conversation.groups
    groups.all.map do |group|
      group.name if group != current_group
    end.compact.to_set
  end


end
