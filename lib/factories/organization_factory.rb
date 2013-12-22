factory :organization do
  name        { Faker::Company.name }
  description { Faker::Company.bs }
end
