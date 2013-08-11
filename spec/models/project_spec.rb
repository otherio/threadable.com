require 'spec_helper'

describe Project do

  it "should require a name" do
    project = Project.new
    project.save.should be_false
    project.errors[:name].should == ["can't be blank"]

    project.name = 'build a hyper cube'
    project.save.should be_true
    project.errors.should be_blank
  end

  it "should require a uniq name" do
    project = Project.new(name: 'build a fire proof house')
    project.save.should be_true

    project = Project.new(name: 'build a fire proof house')
    project.save.should be_false
    project.errors[:name].should == ["has already been taken"]
  end

  context "when not given a slug" do
    it "should be created from the name if blank" do
      project = Project.create(name: 'Fall down a hole')
      project.slug.should == 'fall-down-a-hole'
    end
  end

  describe "#short_name=" do

    context "when the name is 'Langworth, Barton and Strosin ™'" do
      let(:project){ Project.create(name: name, short_name: short_name) }
      let(:name){ "Langworth, Barton and Strosin ™" }
      context "and the short_name is nil" do
        let(:short_name){ nil }
        describe "#slug" do
          subject{ project.slug }
          it { should == 'langworth-barton-and-strosin'}
        end
        describe "#subject_tag" do
          subject{ project.subject_tag }
          it { should == 'Langworth Barton and Strosin'}
        end
        describe "#email_address_username" do
          subject{ project.email_address_username }
          it { should == 'langworth.barton.and.strosin'}
        end
      end

      context "and the short_name is 'LBS'" do
        let(:short_name){ "LBS ™" }
        describe "#slug" do
          subject{ project.slug }
          it { should == 'lbs'}
        end
        describe "#subject_tag" do
          subject{ project.subject_tag }
          it { should == 'LBS'}
        end
        describe "#email_address_username" do
          subject{ project.email_address_username }
          it { should == 'lbs'}
        end
      end
    end
  end

  describe "#email_address" do
    it "should return a email address" do
      project = Project.create(name: 'Bob', short_name: 'hole-faller')
      smtp_domain = Rails.application.config.action_mailer.smtp_settings[:domain]
      project.email_address.should == "hole.faller@#{smtp_domain}"
    end
  end

  describe "#formatted_email_address" do
    it "should return a formatted email address" do
      project = Project.create(name: 'Bob', short_name: 'hole-faller')
      project.formatted_email_address.should == "Bob <#{project.email_address}>"
    end
  end

end
