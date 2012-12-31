FactoryGirl.define do
  factory :task do
    name        { Faker::Company.catch_phrase }
    project
  end
end
