FactoryGirl.define do
  factory :task do
    subject { Faker::Company.catch_phrase }
    project
  end
end
