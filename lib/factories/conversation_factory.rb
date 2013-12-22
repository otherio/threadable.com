factory :conversation do
  subject { Faker::Company.bs }
  organization
  creator {
    organization.members.sample or begin
      user = create(:user)
      organization.members << user
      user
    end
  }
end
