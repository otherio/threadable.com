require 'spec_helper'

describe "Email actions" do

  let(:project) { Project.where(name: "UCSD Electric Racing").first! }
  let(:task){ project.tasks.first! }
  let(:current_user){ task.doers.with_password.first! }

  before do
    sign_in_as current_user
  end

  describe "ill do it" do
    let(:uri){ project_task_ill_do_it_path(project, task) }
    let(:current_user){ (project.members.with_password - task.doers).first }

    it "should add me as a doer to the task" do
      visit uri
      expect(page).to have_content "Notice! You have been added as a doer of this task."
      expect(task.reload.doers).to include current_user
      expect(current_path).to eq project_conversation_path(project,task)
      expect(page).to have_content "#{current_user.name} added #{current_user.name} as a doer"
    end
  end

  describe "remove me" do
    let(:uri){ project_task_remove_me_path(project, task) }

    it "should remove me as a doer from the task" do
      visit uri
      expect(page).to have_content "Notice! You have been removed from the doers of this task."
      expect(task.reload.doers).to_not include current_user
      expect(current_path).to eq project_conversation_path(project,task)
      expect(page).to have_content "#{current_user.name} removed #{current_user.name} as a doer"
    end
  end

  describe "mark as done" do
    let(:task){ project.tasks.not_done.with_doers.first! }
    let(:uri){ project_task_mark_as_done_path(project, task) }

    it "should mark the task as done" do
      visit uri
      expect(page).to have_content "Notice! Task marked as done."
      expect(task.reload).to be_done
      expect(current_path).to eq project_conversation_path(project,task)
      expect(page).to have_content "#{current_user.name} marked this task as done"
    end
  end

  describe "mark as undone" do
    let(:task){ project.tasks.done.with_doers.first! }
    let(:uri){ project_task_mark_as_undone_path(project, task) }

    it "should mark the task as undone" do
      visit uri
      expect(page).to have_content "Notice! Task marked as not done."
      expect(page).to have_content "#{current_user.name} marked this task as not done"
      expect(current_path).to eq project_conversation_path(project,task)
      task.reload
      expect(task.reload).to_not be_done
    end
  end

end
