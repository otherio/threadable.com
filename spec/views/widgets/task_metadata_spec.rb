require 'spec_helper'

describe "task_metadata" do

  let(:user) { create(:user) }
  let(:task) { create(:task) }

  def locals
    {
      task: task,
      user: user
    }
  end

  before do
    task.project.members << user
  end

  context "when the current user is not a doer" do
    it "shows a sign me up link" do
      return_value.should =~ /sign me up/
    end
  end

  context "when the current user is a doer" do
    before do
      task.doers << user
    end

    it "shows a remove me link" do
      return_value.should =~ /remove me/
    end
  end

end
