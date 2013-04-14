FactoryGirl.define do
  factory :message do
    subject { Faker::Company.catch_phrase }
    body_plain { Faker::HipsterIpsum.paragraph }
    conversation
    user
    from { user.email }
  end
end
