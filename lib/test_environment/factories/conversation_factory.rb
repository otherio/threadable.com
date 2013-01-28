FactoryGirl.define do
  factory :conversation do
    subject { Faker::Company.bs }
    project
  end
end
