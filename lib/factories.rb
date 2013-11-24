require 'factory_girl'
require 'ffaker'

Factories = FactoryGirl

FactoryGirl.define do

  Dir[Rails.root+'lib/factories/*.rb'].each do |path|
    instance_eval File.read(path)
  end

end
