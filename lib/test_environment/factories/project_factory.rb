FactoryGirl.define do
  factory :project, :class => "Covered::Project" do
    name        { Faker::Company.name }
    description { Faker::Company.bs }
  end
end
