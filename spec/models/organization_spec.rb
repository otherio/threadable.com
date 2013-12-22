require 'spec_helper'

describe Organization do

  it "should require a name" do
    project = Organization.new
    project.save.should be_false
    project.errors[:name].should == ["can't be blank"]

    project.name = 'build a hyper cube'
    project.save.should be_true
    project.errors.should be_blank
  end

  it "should require a uniq name" do
    project = Organization.new(name: 'build a fire proof house')
    project.save.should be_true

    project = Organization.new(name: 'build a fire proof house')
    project.save.should be_false
    project.errors[:name].should == ["has already been taken"]
  end

  context "when not given a slug" do
    it "should be created from the name if blank" do
      project = Organization.create(name: 'Fall down a hole')
      project.slug.should == 'fall-down-a-hole'
    end
  end

  describe "#short_name=" do

    context "when the name is 'Langworth, Barton and Strosin ™'" do
      let(:project){ Organization.create(name: name, short_name: short_name) }
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
          it { should == 'langworth-barton-and-strosin'}
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

  describe "#slug" do
    it "should be generated from the short name" do
      project = Organization.create(name: 'Fly to the moon', short_name: 'Moon Mission')
      expect(project.slug).to eq 'moon-mission'
      project.update_attributes(short_name: 'Mission to Moon')
      expect(project.slug).to eq 'mission-to-moon'
    end
  end

end
