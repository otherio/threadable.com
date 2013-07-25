When /^I show the quoted text for the message containing "(.*?)"$/ do |contents|
  within find('.message', text: contents) do
    find('.show-quoted-text').click
  end
end

When /^I send the message "(.*?)"$/ do |value|
  fill_in_new_conversation_message body: value, send: true
end

