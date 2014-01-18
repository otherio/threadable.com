require 'spec_helper'

describe "Email actions" do

  # include RSpec::States

  # let(:organization_slug){ 'raceteam' }
  # let(:task_slug   ){ 'layup-body-carbon' }
  # let(:organization     ){ current_user.organizations.find_by_slug!(organization_slug) }
  # let(:task        ){ organization.tasks.find_by_slug!(task_slug) }

  # define_state %(the task is done) do
  #   let(:task_slug){ 'layup-body-carbon' }
  # end

  # define_state %(the task is not done) do
  #   let(:task_slug){ 'trim-body-panels' }
  # end

  # define_state %r(\AI am "(.+)"\Z) do |email_address|
  #   before{ covered.current_user_id = find_user_by_email_address(email_address).id }
  # end

  # define_state %r(\AI am signed in as "(.+)"\Z) do |email_address|
  #   before{ sign_in_as email_address }
  # end

  # define_state %(I am not signed in) do
  # end

  # define_state %(I am a doer of the task) do
  #   import_state %(I am "tom@ucsd.example.com")
  # end

  # define_state %(I am not a doer of the task) do
  #   import_state %(I am "bob@ucsd.example.com")
  # end

  # define_state %(I am signed in as a doer of the task) do
  #   import_state %(I am signed in as "tom@ucsd.example.com")
  # end

  # define_state %(I am signed in as a non-doer of the task) do
  #   import_state %(I am signed in as "bob@ucsd.example.com")
  # end

  # # %(I follow the "mark as done" button in my email) do
  # define_state %r(\AI follow the "(.+)" button in my email\Z) do |button|
  #   case button
  #   when "mark as done"
  #     let(:url){ organization_task_mark_as_done_url(organization_slug, task_slug) }
  #   when "mark as undone"
  #     let(:url){ organization_task_mark_as_undone_url(organization_slug, task_slug) }
  #   when "I'll do it"
  #     let(:url){ organization_task_ill_do_it_url(organization_slug, task_slug) }
  #   when "remove me"
  #     let(:url){ organization_task_remove_me_url(organization_slug, task_slug) }
  #   when "view on covered"
  #     let(:url){ organization_conversation_url(organization_slug, task_slug) }
  #   end
  #   before{ visit url }
  # end

  # define_it_should "ask me to sign in" do
  #   expect(current_url).to eq sign_in_url(r:url)
  #   sign_in_as 'bob@ucsd.example.com'
  # end

  # define_it_should "not ask me to sign in" do
  #   expect(current_path).to_not eq sign_in_path
  # end

  # define_it_should %r{\Ashow a notice saying "(.+)"\Z} do |notice|
  #   expect(page).to have_text "Notice! #{notice}"
  # end

  # define_it_should %r{\Anot show a notice saying "(.+)"\Z} do |notice|
  #   expect(page).to_not have_text "Notice! #{notice}"
  # end

  # define_it_should %(have an event saying the current user marked this task as done) do
  #   expect(page).to have_text "#{current_user.name} marked this task as done"
  # end

  # define_it_should %(not have an event saying the current user marked this task as done) do
  #   expect(page).to_not have_text "#{current_user.name} marked this task as done"
  # end

  # define_it_should %(have an event saying the current user marked this task as not done) do
  #   expect(page).to have_text "#{current_user.name} marked this task as not done"
  # end

  # define_it_should %(not have an event saying the current user marked this task as not done) do
  #   expect(page).to_not have_text "#{current_user.name} marked this task as not done"
  # end

  # define_it_should 'be on the task show page' do
  #   expect(current_url).to eq organization_conversation_url(organization_slug, task_slug)
  # end

  # define_it_should "mark the task as done" do
  #   expect(page).to have_link 'mark as not done'
  #   expect(page).to have_text task.subject
  #   expect(current_url).to eq organization_conversation_url(organization_slug, task_slug)
  #   expect(task).to be_done
  # end



  # describe "I'll do it" do

  #   state %(I am signed in as a doer of the task), %(I follow the "I'll do it" button in my email) do
  #     it_should(
  #       %(not show a notice saying "You have been added as a doer of this task."),
  #       %(be on the task show page),
  #     )
  #   end

  #   state %(I am signed in as a non-doer of the task), %(I follow the "I'll do it" button in my email) do
  #     it_should(
  #       %(show a notice saying "You have been added as a doer of this task."),
  #       %(be on the task show page),
  #     )
  #   end

  #   state %(I am not signed in), %(I follow the "I'll do it" button in my email) do
  #     it_should(
  #       %(ask me to sign in),
  #       %(show a notice saying "You have been added as a doer of this task."),
  #       %(be on the task show page),
  #     )
  #   end

  # end

  # describe "remove me" do

  #   state %(I am signed in as a doer of the task), %(I follow the "remove me" button in my email) do
  #     it_should(
  #       %(show a notice saying "You have been removed from the doers of this task."),
  #       %(be on the task show page),
  #     )
  #   end

  #   state %(I am signed in as a non-doer of the task), %(I follow the "remove me" button in my email) do
  #     it_should(
  #       %(not show a notice saying "You have been removed from the doers of this task."),
  #       %(be on the task show page),
  #     )
  #   end

  # end

  # describe "mark as done" do

  #   state %(I am signed in as "bob@ucsd.example.com") do
  #     state %(the task is not done), %(I follow the "mark as done" button in my email) do
  #       it_should(
  #         %(show a notice saying "Task marked as done."),
  #         %(have an event saying the current user marked this task as done),
  #         %(be on the task show page),
  #       )
  #     end
  #     state %(the task is done), %(I follow the "mark as done" button in my email) do
  #       it_should(
  #         %(not show a notice saying "Task marked as done."),
  #         %(not have an event saying the current user marked this task as done),
  #         %(be on the task show page),
  #       )
  #     end
  #   end

  # end

  # describe "mark as undone" do

  #   state %(I am signed in as "bob@ucsd.example.com") do
  #     state %(the task is done), %(I follow the "mark as undone" button in my email) do
  #       it_should(
  #         %(show a notice saying "Task marked as not done."),
  #         %(have an event saying the current user marked this task as not done),
  #         %(be on the task show page),
  #       )
  #     end
  #     state %(the task is not done), %(I follow the "mark as undone" button in my email) do
  #       it_should(
  #         %(not show a notice saying "Task marked as not done."),
  #         %(not have an event saying the current user marked this task as not done),
  #         %(be on the task show page),
  #       )
  #     end
  #   end

  # end

  # describe "view on covered" do
  #   state %(I am signed in as "bob@ucsd.example.com"), %(I follow the "view on covered" button in my email) do
  #     it_should(
  #       %(be on the task show page),
  #     )
  #   end

  #   state %(I am not signed in), %(I follow the "view on covered" button in my email) do
  #     it_should(
  #       %(ask me to sign in),
  #       %(be on the task show page),
  #     )
  #   end
  # end

end
