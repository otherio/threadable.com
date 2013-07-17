When /^I show the quoted text for the message containing "(.*?)"$/ do |contents|
  within find('.message', text: contents) do
    find('.show-quoted-text').click
  end
end

When /^I send the message "(.*?)"$/ do |value|
  find_field('Add your voice...').click
  page.execute_script <<-JS
    $('.new_conversation_message').widget().setMessageBody(#{value.inspect});
  JS
  click_button 'Send'
end

