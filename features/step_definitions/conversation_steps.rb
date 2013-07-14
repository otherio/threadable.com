When /^I show the quoted text for the message containing "(.*?)"$/ do |contents|
  within find('.message', text: contents) do
    find('.show-quoted-text').click
  end
end

When /^I send the message "(.*?)"$/ do |value|
  # this is sort of shitty to work around capybara's broken iframe handling
  fill_in 'Add your voice...', with: value
  page.execute_script( "$('form.new_message').submit();" )
end

