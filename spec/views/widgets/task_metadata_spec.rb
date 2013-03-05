require 'spec_helper'

describe "task_metadata" do

  let(:current_user) { FactoryGirl.create(:user) }
  let(:task) { FactoryGirl.create(:task) }

  def locals
    {
      task: task,
      current_user: current_user
    }
  end

  before do
    task.project.members << current_user
  end

  context "when the current user is not a doer" do
    it "shows a sign me up link" do
      return_value.should =~ /sign me up/
    end
  end

  context "when the current user is a doer" do
    before do
      task.doers << current_user
    end

    it "shows a remove me link" do
      return_value.should =~ /remove me/
    end
  end

end
