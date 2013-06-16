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

  context "when given a slug" do
    it "should take that slug" do
      project = Project.create(name: 'Fall down a hole', slug: 'hole-faller')
      project.slug.should == 'hole-faller'
    end
  end

  describe "#email_address" do
    it "should return a email address" do
      project = Project.create(name: 'Bob', slug: 'hole-faller')
      smtp_domain = Rails.application.config.action_mailer.smtp_settings[:domain]
      project.email_address.should == "hole-faller@#{smtp_domain}"
    end
  end

  describe "#formatted_email_address" do
    it "should return a formatted email address" do
      project = Project.create(name: 'Bob', slug: 'hole-faller')
      project.formatted_email_address.should == "Bob <#{project.email_address}>"
    end
  end

  describe "#subject_tag" do
    context "when the project has a defined subject tag" do
      let(:project) { Project.create(subject_tag: 'i am a tag', name: "Baby's First Project")}

      it "returns the defined subject tag" do
        project.subject_tag.should == 'i am a tag'
      end
    end

    context "when the project has no custom subject tag" do
      let(:project) { Project.create(name: "Baby's First Project")}

      it "returns the default subject tag" do
        project.subject_tag.should == 'babys-f'
      end
    end

  end

end
