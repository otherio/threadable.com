require 'spec_helper'

describe "Email actions" do

  let(:project) { Covered::Project.where(name: "UCSD Electric Racing").first! }
  let(:recipient){ project.members.who_get_email.first! }
  let(:sender){ (project.members.who_get_email - [recipient]).first }
  let(:current_user){ sender }
  let(:message){
    covered.messages.create(
      project_slug:      project.slug,
      conversation_slug: conversation.slug,
      message_attributes: {body: "hello there"},
    )
  }
  let(:email){ sent_emails.sent_to(recipient.email).last or raise "sent email to #{recipient.email} not found"}
  let(:html_part){ Nokogiri::HTML.fragment email.html_part.body.to_s }
  let(:text_part){ email.text_part.body.to_s }

  let :covered_buttons do
    html_part.css('a.covered-button').map do |a|
      text, href = a.text, a[:href]
      text.gsub!(/[^\w'\s]/,'')
      href.sub! 'localhost:3010', 'www.example.com' # this is bullshit
      [text, href]
    end.to_set
  end

  before do
    message # create message
    drain_background_jobs!
  end

  def covered_button name
    href = case name
    when "I'll do it";       project_task_ill_do_it_url(project, conversation)
    when "Remove me";        project_task_remove_me_url(project, conversation)
    when "Mark as done";     project_task_mark_as_done_url(project, conversation)
    when "Mark as undone";   project_task_mark_as_undone_url(project, conversation)
    when "New conversation"; "mailto:#{project.email}"
    when "New task";         "mailto:#{project.email}?subject=%E2%9C%94+"
    when "View on Covered";  project_conversation_url(project, conversation, anchor: "message-#{message.id}")
    when "Mute";             project_conversation_url(project, conversation, anchor: "message-#{message.id}")
    else; raise "unknown name #{name}"
    end
    [name, href]
  end

  context "given I have received a conversation message" do

    context "that is not a task" do
      let(:conversation){ project.conversations.not_task.first! }
      it "it should have the expected action buttons" do
        expect(covered_buttons).to include covered_button "New conversation"
        expect(covered_buttons).to include covered_button "New task"
        expect(covered_buttons).to include covered_button "View on Covered"
        expect(covered_buttons).to include covered_button "Mute"
      end
    end

    context "that is a task" do
      let(:task){ project.tasks.with_doers.done.first! }
      let(:recipient){ task.doers.first! }
      let(:conversation){ task }

      context "that is done" do
        it "it should have the expected action buttons" do
          expect(covered_buttons).to include covered_button "Remove me"
          expect(covered_buttons).to include covered_button "Mark as undone"
          expect(covered_buttons).to include covered_button "New conversation"
          expect(covered_buttons).to include covered_button "New task"
          expect(covered_buttons).to include covered_button "View on Covered"
          expect(covered_buttons).to include covered_button "Mute"
        end
      end

      context "that is not done" do
        let(:task){ project.tasks.with_doers.not_done.first! }
        it "it should have the expected action buttons" do
          expect(covered_buttons).to include covered_button "Remove me"
          expect(covered_buttons).to include covered_button "Mark as done"
          expect(covered_buttons).to include covered_button "New conversation"
          expect(covered_buttons).to include covered_button "New task"
          expect(covered_buttons).to include covered_button "View on Covered"
          expect(covered_buttons).to include covered_button "Mute"
        end
      end

      context "that I am not a doer for" do
        let(:recipient){ (project.members.who_get_email - task.doers).first }
        it "it should have the expected action buttons" do
         expect(covered_buttons).to include covered_button "I'll do it"
          expect(covered_buttons).to include covered_button "Mark as undone"
          expect(covered_buttons).to include covered_button "New conversation"
          expect(covered_buttons).to include covered_button "New task"
          expect(covered_buttons).to include covered_button "View on Covered"
          expect(covered_buttons).to include covered_button "Mute"
        end
      end

      context "that I am a doer for" do
        it "it should have the expected action buttons" do
          expect(covered_buttons).to include covered_button "Remove me"
          expect(covered_buttons).to include covered_button "Mark as undone"
          expect(covered_buttons).to include covered_button "New conversation"
          expect(covered_buttons).to include covered_button "New task"
          expect(covered_buttons).to include covered_button "View on Covered"
          expect(covered_buttons).to include covered_button "Mute"
        end
      end

    end

  end


end
