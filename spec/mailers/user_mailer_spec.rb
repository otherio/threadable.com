require "spec_helper"

describe UserMailer do

  describe "unsubscribe_notice" do
    let(:project){ Project.find_by_name('UCSD Electric Racing') }
    let(:user){ project.members.first }
    let(:mail) { UserMailer.unsubscribe_notice(project: project, user: user, host:'example.com', port:3000) }

    it "should return the expected mail" do
      mail.subject.should == "You've been unsubscribed from #{project.name}"
      mail.to.should == [user.email]
      mail.from.should == ["#{project.slug}@multifyapp.com"]
      mail.body.encoded.should include %(You've been unsubscribed from the "#{project.name}" project on Multify.)


      mail.body.encoded =~ /example\.com:3000\/#{Regexp.escape(project.slug)}\/subscribe\/(\S+)/

      unsubscribe_token = $1
      unsubscribe_token.should_not be_blank
      unsubscribe_token = URI.decode(unsubscribe_token)
      UnsubscribeToken.decrypt(unsubscribe_token).should == [project.id, user.id]


    end
  end

end
