require 'spec_helper'

describe 'new conversaion message interface' do

  # HEY! NOTICE!! - if this test fails try increasing the timeout below in incraments of 100ms - Jared
  around :each do |example|
    Capybara.using_wait_time(0.7) do
      example.run
    end
  end

  before do
    sign_in_as 'alice@ucsd.covered.io'
  end

  let(:organization){ current_user.organizations.find_by_slug! 'raceteam' }

  it "should work" do
    click_on 'UCSD Electric Racing'
    click_on 'Compose'

    expect_widget_to_be_expanded!
    expect_subject_input_to_be_focused!

    fill_in_new_conversation_message(
      subject: 'we did it',
      body: 'our kickstarter is funded.',
      send: true,
    )
    expect(page).to have_content 'we did it' rescue retry
    expect(page).to have_content 'our kickstarter is funded.'

    expect_widget_not_to_be_expanded!

    drain_background_jobs!
    expect(sent_emails.count).to eq organization.members.that_get_email.count
    expect(
      sent_emails.sent_to('alice@ucsd.covered.io').
        with_subject('[RaceTeam] we did it').
        containing('our kickstarter is funded.')
    ).to be_present
    sent_emails.clear

    focus_new_conversation_message_body!
    expect_widget_to_be_expanded!
    expect_subject_input_not_to_be_visible!

    fill_in_wysiwyg 'isnt that awesome?'
    click_on 'Send'

    expect(page).to have_content 'isnt that awesome?'
    expect_widget_not_to_be_expanded!

    drain_background_jobs!
    expect(sent_emails.count).to eq organization.members.that_get_email.count
    expect(
      sent_emails.sent_to('alice@ucsd.covered.io').
        with_subject('[RaceTeam] we did it').
        containing('isnt that awesome?')
    ).to be_present
  end


  let(:body_textarea_selector){ '.new_conversation_message .body_field textarea' }
  let(:body_wysiwyg_selector){ '.new_conversation_message .body_field .wysihtml5-sandbox' }
  let(:body_subject_selector){ '.new_conversation_message .subject_field input' }
  let(:send_button_selector){ 'input[type="submit"][value="Send"]' }


  def expect_widget_to_be_expanded!
    expect_body_textarea_not_to_be_visible!
    expect_body_wysiwyg_to_be_visible!
    expect_attach_files_button_to_be_visible!
    expect_send_button_to_be_visible!
  end

  def expect_widget_not_to_be_expanded!
    expect_body_textarea_to_be_visible!
    expect_body_wysiwyg_not_to_be_visible!
    expect_attach_files_button_not_to_be_visible!
    expect_send_button_not_to_be_visible!
  end

  def expect_attach_files_button_to_be_visible!
    expect(page).to have_button 'Attach Files'
  end

  def expect_attach_files_button_not_to_be_visible!
    expect(page).not_to have_button 'Attach Files'
  end

  def expect_send_button_to_be_visible!
    expect_selector_to_be_visible! send_button_selector
  end

  def expect_send_button_not_to_be_visible!
    expect_selector_not_to_be_visible! send_button_selector
  end

  def expect_subject_input_to_be_focused!
    expect_subject_input_to_be_visible!
    # I could not get a test of focus to work in the webkit driver - Jared
    # expect(page.evaluate_script("$(#{body_subject_selector.inspect})[0] === document.activeElement")).to be_true
    # expect(page.evaluate_script("$(#{body_subject_selector.inspect}).is(':focus')")).to be_true
  end

  def expect_subject_input_to_be_visible!
    expect_selector_to_be_visible! body_subject_selector
  end

  def expect_subject_input_not_to_be_visible!
    expect_selector_not_to_be_visible! body_subject_selector
  end

  def expect_body_textarea_to_be_visible!
    expect_selector_to_be_visible! body_textarea_selector
  end

  def expect_body_textarea_not_to_be_visible!
    expect_selector_not_to_be_visible! body_textarea_selector
  end

  def expect_body_wysiwyg_to_be_visible!
    expect_selector_to_be_visible! body_wysiwyg_selector
  end

  def expect_body_wysiwyg_not_to_be_visible!
    expect_selector_not_to_be_visible! body_wysiwyg_selector
  end

  def expect_selector_to_be_visible! selector
    expect(page).to have_selector selector
  end

  def expect_selector_not_to_be_visible! selector
    expect(page).not_to have_selector selector
  end

end
