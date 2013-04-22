When /^I show the quoted text for the message containing "(.*?)"$/ do |contents|
  find(%(.message:contains(#{contents.inspect}) .show-quoted-text)).click
end
