FactoryGirl.define do
  factory :incoming_email, class: 'Covered::IncomingEmail' do
    params { TestEnvironment::IncomingEmailParamsFactory.call }
  end
end
