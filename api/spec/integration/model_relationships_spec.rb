require 'spec_helper'

describe 'model relationships' do


  it "should do all the things" do

    user = User.create!(
      email: 'pinky@thebrain.net',
      name: 'Pinky Mouse',
      password: 'password',
    )

    user.slug.should == 'pinky-mouse'
    user.projects.count.should == 0

    project = user.projects.create!(
      name: 'Take Over The World!',
      description: 'The same thing we do every night.',
    )

    project.slug.should == 'take-over-the-world'

    user.projects.to_a.should == [project]

    project_membership = project.project_memberships.create!(
      user: create(:user)
    )

    project_membership.user.should == User.last
    project_membership.can_write.should be_true
    project_membership.gets_email.should be_true
    project_membership.moderator.should be_false


  end

end
