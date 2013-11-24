factory :incoming_email do
  params { RSpec::Support::IncomingEmailParams::Factory.call }
end
