# Encoding: UTF-8
require "spec_helper"

describe ProjectMembershipMailer do
  let(:project){ find_project('raceteam') }
  let(:current_user){ find_user("alice-neilson") }
  let(:user){ project.members.first }
  let(:project_membership){ project.memberships.where(user:user).first! }

  describe "join_notice" do
    let(:adder){ current_user }
    let(:message){ "yo dude, I added you to the project. Thanks for the help!" }
    subject(:email) do
      covered.generate_email(type: :join_notice, options: {
        project_id:   project.id,
        recipient_id: user.id,
        message:      message,
      })
    end

    context "when the recipient is a web enabled user" do
      # we know Yan Hzu is member of the "UCSD Electric Racing" project and is web enabled
      let(:user){ Covered::User.where(name:'Yan Hzu').first! }

      it "should return the expected message" do
        expect(email.subject     ).to eq "You've been added to #{project.name}"
        expect(email.to          ).to eq [user.email]
        expect(email.from        ).to eq [adder.email]
        expect(email.body.encoded).to include message

        project_unsubscribe_link = URI.extract(email.body.encoded).find{|link| link =~ %r(/unsubscribe/) }
        expect(project_unsubscribe_link).to be_present

        expect(email.body.encoded).to include project_url(project)

        user_setup_url = URI.extract(email.body.encoded).find{|link| link =~ %r(/setup) }
        expect(user_setup_url).not_to be_present

      end
    end

    context "when the recipient is not a web enabled user" do
      # we know Jonathan Spray is member of the "UCSD Electric Racing" project but not web enabled
      let(:user){ Covered::User.where(name:'Jonathan Spray').first! }

      it "should return the expected message" do
        expect(email.subject     ).to eq "You've been added to #{project.name}"
        expect(email.to          ).to eq [user.email]
        expect(email.from        ).to eq [adder.email]
        expect(email.body.encoded).to include message

        project_unsubscribe_link = URI.extract(email.body.encoded).find{|link| link =~ %r(/unsubscribe/) }
        expect(project_unsubscribe_link).to be_present

        user_setup_url = URI.extract(email.body.encoded).find{|link| link =~ %r(/setup) }
        expect(user_setup_url).to be_present

        token = URI.parse(user_setup_url).path[%r{/users/setup/(?<token>.*)}, :token]
        expect(token).to be_present

        user_id, destination_url = UserSetupToken.decrypt(token)
        expect(user_id).to eq user.id
        expect(destination_url).to eq project_path(project)
      end
    end

  end

  describe "unsubscribe_notice" do
    subject(:email) {
      covered.generate_email(type: :unsubscribe_notice, options: {
        project_id:   project.id,
        recipient_id: user.id,
      })
    }
    it "should return the expected message" do
      expect(email.subject      ).to eq "You've been unsubscribed from #{project.name}"
      expect(email.to           ).to eq [user.email]
      expect(email.from         ).to eq [project.email_address]
      expect(email.body.encoded).to include \
        %(You've been unsubscribed from the "#{project.name}" project on Covered.)

      project_resubscribe_url = URI.extract(email.body.encoded).find{|link| link =~ %r(/resubscribe/) }
      expect(project_resubscribe_url).to be_present
    end
  end


end
