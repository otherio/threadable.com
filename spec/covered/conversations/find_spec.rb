require 'spec_helper'

describe Covered::Conversations::Find do

  cases = {
    'amy-wong' => {
      {                                         } => -> { current_user.conversations.to_a },
      { first: true                             } => -> { current_user.conversations.first },
      { project_slug: "sfhealth"                } => -> { current_user.conversations.joins(:project).where(projects:{slug: 'sfhealth'}).to_a },
      { project_slug: "sfhealth", first: true   } => -> { current_user.conversations.joins(:project).where(projects:{slug: 'sfhealth'}).first },
      { project_slug: "raceteam"                } => -> { [] },
      { project_slug: "raceteam", first: true   } => -> { nil },
      { project_slug: "spaceteam"               } => -> { [] },
      { project_slug: "spaceteam", first: true  } => -> { nil },
    },
    'alice-neilson' => {
      {                                         } => -> { current_user.conversations.to_a },
      { first: true                             } => -> { current_user.conversations.first },
      { project_slug: "raceteam"                } => -> { current_user.conversations.joins(:project).where(projects:{slug: 'raceteam'}).to_a },
      { project_slug: "raceteam", first: true   } => -> { current_user.conversations.joins(:project).where(projects:{slug: 'raceteam'}).first },
      { project_slug: "sfhealth"                } => -> { [] },
      { project_slug: "sfhealth", first: true   } => -> { nil },
      { project_slug: "spaceteam"               } => -> { [] },
      { project_slug: "spaceteam", first: true  } => -> { nil },
    },
    'john-callas' => {
      {                                         } => -> { current_user.conversations.to_a },
      { first: true                             } => -> { current_user.conversations.first },
      { project_slug: "spaceteam"               } => -> { current_user.conversations.joins(:project).where(projects:{slug: 'spaceteam'}).to_a },
      { project_slug: "spaceteam", first: true  } => -> { current_user.conversations.joins(:project).where(projects:{slug: 'spaceteam'}).first },
      { project_slug: "sfhealth"                } => -> { [] },
      { project_slug: "sfhealth", first: true   } => -> { nil },
      { project_slug: "raceteam"                } => -> { [] },
      { project_slug: "raceteam", first: true   } => -> { nil },
    },
  }

  cases.each do |user_slug, contexts|
    context "when the current user is #{user_slug}" do
      let(:current_user){ find_user(user_slug) }
      contexts.each do |options, block|
        context "when given #{options.inspect}" do
          subject{ covered.conversations.find(options) }
          it { should == instance_exec(&block) }
        end
      end
    end
  end


end
