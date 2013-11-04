require 'spec_helper'

describe Covered::Projects::Find do

  cases = {
    'amy-wong' => {
      {                                } => -> { current_user.projects.to_a },
      { first: true                    } => -> { current_user.projects.first },
      { slug: "sfhealth"               } => -> { current_user.projects.where(slug: 'sfhealth').to_a },
      { slug: "sfhealth", first: true  } => -> { current_user.projects.where(slug: 'sfhealth').first },
      { slug: "raceteam"               } => -> { []  },
      { slug: "raceteam", first: true  } => -> { nil },
      { slug: "spaceteam"              } => -> { []  },
      { slug: "spaceteam", first: true } => -> { nil },
    },
    'alice-neilson' => {
      {                                } => -> { current_user.projects.to_a },
      { first: true                    } => -> { current_user.projects.first },
      { slug: "raceteam"               } => -> { current_user.projects.where(slug: 'raceteam').to_a },
      { slug: "raceteam", first: true  } => -> { current_user.projects.where(slug: 'raceteam').first },
      { slug: "sfhealth"               } => -> { []  },
      { slug: "sfhealth", first: true  } => -> { nil },
      { slug: "spaceteam"              } => -> { []  },
      { slug: "spaceteam", first: true } => -> { nil },
    },
    'john-callas' => {
      {                                } => -> { current_user.projects.to_a },
      { first: true                    } => -> { current_user.projects.first },
      { slug: "spaceteam"              } => -> { current_user.projects.where(slug: 'spaceteam').to_a },
      { slug: "spaceteam", first: true } => -> { current_user.projects.where(slug: 'spaceteam').first },
      { slug: "sfhealth"               } => -> { []  },
      { slug: "sfhealth", first: true  } => -> { nil },
      { slug: "raceteam"               } => -> { []  },
      { slug: "raceteam", first: true  } => -> { nil },
    },
  }

  cases.each do |user_slug, contexts|
    context "when the current user is #{user_slug}" do
      let(:current_user){ find_user(user_slug) }
      contexts.each do |options, block|
        context "when given #{options.inspect}" do
          subject{ covered.projects.find(options) }
          it { should == instance_exec(&block) }
        end
      end
    end
  end

end
