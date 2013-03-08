FactoryGirl.define do
  factory :message do
    subject { Faker::Company.catch_phrase }
    body { Faker::HipsterIpsum.paragraph }
    conversation
    user
    from { user.email }
  end
end
