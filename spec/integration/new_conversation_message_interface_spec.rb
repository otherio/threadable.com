require 'spec_helper'

describe 'new conversaion message interface' do
  around :each do |example|
    Capybara.using_wait_time(0.5) do
      example.run
    end
  end

  it "" do
    login_as User.where(name: "Alice Neilson").first!
    click_on 'UCSD Electric Racing'
    click_on 'Compose'

    expect_widget_to_be_expanded!
    expect_subject_input_to_be_focused!
    within '.new_conversation_message' do
      fill_in 'subject', with: 'we did it'
      fill_in_wysiwyg 'our kickstarter is funded.'
      click_on 'Send'
    end

    expect(page).to have_content 'we did it'
    expect(page).to have_content 'our kickstarter is funded.'

    expect_widget_not_to_be_expanded!

    find_field('Add your voice...').click
    expect_widget_to_be_expanded!
    expect_subject_input_not_to_be_visible!

    fill_in_wysiwyg 'isnt that awesome?'
    click_on 'Send'

    expect(page).to have_content 'isnt that awesome?'
    expect_widget_not_to_be_expanded!
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
    expect(page.evaluate_script("$(#{body_subject_selector.inspect}).is(':focus')")).to be_true
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

  def fill_in_wysiwyg value
    page.execute_script <<-JS
      $('.wysihtml5-sandbox:first').contents().find("body").html(#{value.inspect});
    JS
  end

end
