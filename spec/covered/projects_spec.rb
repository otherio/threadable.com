require 'spec_helper'

describe Covered::Projects do

  let(:current_user){ find_user 'alice-neilson' }

  subject{ described_class.new covered }

  before{ current_user.projects.size.should > 0 }

  describe "#covered" do
    it "should eq the given instance of Covered" do
      expect(subject.covered).to eq covered
    end
  end

  describe "#all" do
    it "should an array of projects for the current_user" do
      expect( subject.all ).to eq covered.current_user.projects
    end
  end

  describe "#find" do
    it "should an array of projects for the current_user" do
      expect( subject.find ).to eq covered.current_user.projects
      expect( subject.find(first: true) ).to eq covered.current_user.projects.first!
      expect( subject.find(slug: 'raceteam', first: true) ).to eq find_project('raceteam')
    end
  end

  describe "#get" do
    it "should take a Covered::Project#slug and the project" do
      expect( subject.get(slug:'raceteam' ) ).to eq find_project('raceteam')
      expect( subject.get(slug:'spaceteam') ).to be_nil
    end
  end

  describe "#first" do

  end

  describe "#new" do

  end

  describe "#create" do

  end

  describe "#update" do

  end

  describe "#join" do

  end

  describe "#leave" do

  end

  describe "#destroy" do

  end

end
