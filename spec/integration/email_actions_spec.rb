require 'spec_helper'

describe "Email actions" do

  when_signed_in_as 'bethany@ucsd.covered.io' do
    let(:organization  ){ current_user.organizations.find_by_slug! 'raceteam' }
    let(:sender   ){ current_user }
    let(:recipient){ organization.members.find_by_user_id! find_user_by_email_address('bob@ucsd.covered.io').id }
    let(:message  ){ conversation.messages.create! text: 'I dont agree with any of you. I hate this team. I quit!' }
    let(:email    ){ sent_emails.to(recipient.email_address).last or raise "unable to find email" }
    let(:html_part){ Nokogiri::HTML.fragment email.html_part.body.to_s }
    let(:text_part){ email.text_part.body.to_s }

    let :covered_buttons do
      html_part.css('a.covered-button').map do |a|
        text, href = a.text, a[:href]
        text.gsub!(/[^\w'\s]/,'')
        [text, href]
      end.to_set
    end


    before do
      message
      SendEmailWorker.drain
    end

    def covered_button name
      href = case name
      when "I'll do it";       organization_task_ill_do_it_url(organization, conversation)
      when "Remove me";        organization_task_remove_me_url(organization, conversation)
      when "Mark as done";     organization_task_mark_as_done_url(organization, conversation)
      when "Mark as undone";   organization_task_mark_as_undone_url(organization, conversation)
      when "New conversation"; "mailto:#{URI::encode(organization.formatted_email_address)}"
      when "New task";         "mailto:#{URI::encode(organization.formatted_task_email_address)}"
      when "View on Covered";  organization_conversation_url(organization, conversation, anchor: "message-#{message.id}")
      when "Mute";             organization_conversation_url(organization, conversation, anchor: "message-#{message.id}")
      else; raise "unknown name #{name}"
      end
      [name, href]
    end

    context "given a conversation message email was sent" do

      context "for a conversation" do
        let(:conversation){ organization.conversations.find_by_slug! 'how-are-we-going-to-build-the-body' }
        it "it should have the expected action buttons" do
          expect(covered_buttons).to include covered_button "New conversation"
          expect(covered_buttons).to include covered_button "New task"
          expect(covered_buttons).to include covered_button "View on Covered"
          # expect(covered_buttons).to include covered_button "Mute"
        end
      end

      context "for a task" do
        let(:conversation){ task }

        before{ expect(task).to be_task }

        context "that is done" do
          let(:task){ organization.conversations.find_by_slug! 'layup-body-carbon' }
          before{ expect(task).to be_done }
          it "it should have the expected action buttons" do
            expect(covered_buttons).to include covered_button "I'll do it"
            expect(covered_buttons).to include covered_button "Mark as undone"
            expect(covered_buttons).to include covered_button "New conversation"
            expect(covered_buttons).to include covered_button "New task"
            expect(covered_buttons).to include covered_button "View on Covered"
            # expect(covered_buttons).to include covered_button "Mute"
          end
        end

        context "that is not done" do
          let(:task){ organization.conversations.find_by_slug! "trim-body-panels" }
          before{ expect(task).to_not be_done }
          it "it should have the expected action buttons" do
            expect(covered_buttons).to include covered_button "I'll do it"
            expect(covered_buttons).to include covered_button "Mark as done"
            expect(covered_buttons).to include covered_button "New conversation"
            expect(covered_buttons).to include covered_button "New task"
            expect(covered_buttons).to include covered_button "View on Covered"
            # expect(covered_buttons).to include covered_button "Mute"
          end
        end

        context "that the recipient is not a doer for" do
          let(:task){ organization.conversations.find_by_slug! "trim-body-panels" }
          before{ expect(task.doers).to_not include recipient }
          it "it should have the expected action buttons" do
            expect(covered_buttons).to include covered_button "I'll do it"
            expect(covered_buttons).to include covered_button "Mark as done"
            expect(covered_buttons).to include covered_button "New conversation"
            expect(covered_buttons).to include covered_button "New task"
            expect(covered_buttons).to include covered_button "View on Covered"
            # expect(covered_buttons).to include covered_button "Mute"
          end
        end

        context "that the recipient is a doer for" do
          let(:recipient){ organization.members.find_by_user_id! find_user_by_email_address('tom@ucsd.covered.io').id }
          let(:task){ organization.conversations.find_by_slug! "trim-body-panels" }
          before{ expect(task.doers).to include recipient }
          it "it should have the expected action buttons" do
            expect(covered_buttons).to include covered_button "Remove me"
            expect(covered_buttons).to include covered_button "Mark as done"
            expect(covered_buttons).to include covered_button "New conversation"
            expect(covered_buttons).to include covered_button "New task"
            expect(covered_buttons).to include covered_button "View on Covered"
            # expect(covered_buttons).to include covered_button "Mute"
          end
        end

      end

    end

  end


end
