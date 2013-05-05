FactoryGirl.define do
  factory :message do
    subject { Faker::Company.catch_phrase }
    body_plain { Faker::HipsterIpsum.paragraph }
    body_html { '' }
    conversation
    user
    from { user.email }
  end
end
