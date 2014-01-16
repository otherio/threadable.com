require 'spec_helper'

feature "Viewing conversations" do

  before { sign_in_as 'amywong.phd@gmail.com' }

  let(:organization){ current_user.organizations.find_by_slug!('sfhealth') }

  def conversations
    conversations = evaluate_script <<-JS
      $('.conversations-list .all-conversations .conversation').map(function(){
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

  scenario %(In the "My Conversations" section) do
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

end
