require 'spec_helper'

feature "Composing a new message" do

  before {
    sign_in_as 'bethany@ucsd.example.com'
    resize_window_to :large
  }

  def new_message_body
    %(Whos ready to Party!?!?\n\n)+
    %(This Saturday we're throwing a company mixer. Be There or be Square!\n\n)+
    %(Bethany\n)
  end

  def send_new_message!
    click_element 'the compose button'
    fill_in 'subject', with: 'Hey Party People!'
    fill_in 'body', with: new_message_body
    click_on 'Send'
  end

  def expect_new_message_to_be_created!
    expect(page).to have_text new_message_body
    conversation_list_member = first('.conversations-list li')
    expect(conversation_list_member).to have_text 'Bethany'
    expect(conversation_list_member).to have_text '(1)'
    expect(conversation_list_member).to have_text 'moments ago'
    expect(conversation_list_member).to have_text new_message_body[0..10]
  end

  def reply_body
    "Oh yeah! Don't forget to bring your significant other ;)"
  end

  def send_reply!
    fill_in 'body', with: reply_body
    click_on 'Send'
  end

  def expect_reply_to_be_created!
    expect(page).to have_text reply_body
    conversation_list_member = first('.conversations-list li')
    expect(conversation_list_member).to have_text 'Bethany'
    expect(conversation_list_member).to have_text '(2)'
    expect(conversation_list_member).to have_text 'moments ago'
    expect(conversation_list_member).to have_text reply_body[0..10]
  end

  scenario %(In the "My Conversations" section) do
    within_element 'the sidebar' do
      click_on 'My Conversations'
    end
    within_element 'the conversations pane' do
      click_on 'Conversations'
    end
    expect(page).to be_at_url conversations_url('raceteam','my')
    send_new_message!
    expect(page).to be_at_url conversation_url('raceteam','my','hey-party-people')
    expect_new_message_to_be_created!
    send_reply!
    expect(page).to be_at_url conversation_url('raceteam','my','hey-party-people')
    expect_reply_to_be_created!

    # and changing it to a task
    expect( threadable.conversations.find_by_slug!('hey-party-people') ).to_not be_task
    find('.convert-to-task').click
    click_on 'Convert to task'
    wait_until_expectation do
      expect( threadable.conversations.find_by_slug!('hey-party-people') ).to be_task
    end
    find('.convert-to-conversation').click
    click_on 'Convert to conversation'
    wait_until_expectation do
      expect( threadable.conversations.find_by_slug!('hey-party-people') ).to_not be_task
    end
  end

  scenario %(In a group's "Conversations" section) do
    within_element 'the sidebar' do
      click_on 'Fundraising'
    end
    within_element 'the conversations pane' do
      click_on 'Conversations'
    end
    expect(page).to be_at_url conversations_url('raceteam', 'fundraising')
    send_new_message!
    expect(page).to be_at_url conversation_url('raceteam', 'fundraising','hey-party-people')
    expect_new_message_to_be_created!
    send_reply!
    expect(page).to be_at_url conversation_url('raceteam', 'fundraising','hey-party-people')
    expect_reply_to_be_created!
  end
end
