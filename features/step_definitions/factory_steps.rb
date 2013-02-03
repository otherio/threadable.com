Given /^the following (.+):$/ do |thing, table|
  table.hashes.each do |row|
    attributes = {}
    row.each{|k,v| attributes[k.underscore.to_sym] = v}
    create(thing.singularize, attributes)
  end
end

Given /^I am not a member$/ do
end