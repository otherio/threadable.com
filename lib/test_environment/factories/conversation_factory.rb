FactoryGirl.define do
  factory :conversation, :class => "Covered::Conversation" do
    subject { Faker::Company.bs }
    project
    creator {
      project.members.sample or begin
        user = create(:user)
        project.members << user
        user
      end
    }
  end
end
