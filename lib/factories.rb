require 'factory_girl'

FactoryGirl.define do

  Dir[Rails.root+'spec/factories/**/*.rb'].each do |factory|
    eval Pathname(factory).read
  end

end
