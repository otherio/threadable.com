FactoryGirl.define do
  factory :message do
    from { Faker::Internet.email }
    subject { Faker::Company.catch_phrase }
    body { Faker::HipsterIpsum.paragraph }
    conversation
    parent_message { nil }
  end
end
