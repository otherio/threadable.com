require "spec_helper"

describe UserMailer do
  let(:project){ Project.find_by_name('UCSD Electric Racing') }
  let(:user){ project.members.first }

  shared_examples_for :a_user_notice_mail do
    it "returns the expected message" do
      mail.subject.should == expected_subject
      mail.to.should == [user.email]
      mail.from.should == ["#{project.slug}@multifyapp.com"]
      mail.body.encoded.should include find_in_body

      mail.body.encoded =~ /example\.com:3000\/#{Regexp.escape(project.slug)}\/subscribe\/(\S+)/

      unsubscribe_token = $1
      unsubscribe_token.should_not be_blank
      unsubscribe_token = URI.decode(unsubscribe_token)
      UnsubscribeToken.decrypt(unsubscribe_token).should == [project.id, user.id]
    end
  end

  describe "unsubscribe_notice" do
    subject(:mail) { UserMailer.unsubscribe_notice(project: project, user: user, host:'example.com', port:3000) }
    let(:expected_subject) { "You've been unsubscribed from #{project.name}" }
    let(:find_in_body) { %(You've been unsubscribed from the "#{project.name}" project on Multify.) }
    it_behaves_like :a_user_notice_mail
  end

  describe "invite_notice" do
    subject(:mail) { UserMailer.invite_notice(project: project, user: user, host:'example.com', port:3000) }
    let(:expected_subject) { "You've been invited to #{project.name}" }
    let(:find_in_body) { %(You've been invited to the "#{project.name}" project on Multify.) }
    it_behaves_like :a_user_notice_mail
  end
end
