factory :task do
  subject { Faker::Company.catch_phrase }

  organization

  creator {
    organization.members.sample or begin
      user = create(:user)
      organization.members << user
      user
    end
  }
end
