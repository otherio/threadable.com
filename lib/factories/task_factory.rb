factory :task do
  subject { Faker::Company.catch_phrase }

  project

  creator {
    project.members.sample or begin
      user = create(:user)
      project.members << user
      user
    end
  }
end
