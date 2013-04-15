Then /^a message should have hidden quoted text$/ do
  page.should have_selector('.show-quoted-link')
  page.find('.message-text-full', visible: false).should_not be_visible
end

Then /^a message should have visible quoted text$/ do
  page.find('.message-text-full').should be_visible
end
