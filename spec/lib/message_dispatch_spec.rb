require 'spec_helper'

describe MessageDispatch do
  context "sending a message" do

    let(:project)     { Project.find_by_name("UCSD Electric Racing") }
    let(:conversation){ project.conversations.find_by_subject('layup body carbon') }
    let(:message)     { conversation.messages.last }
    let(:sender)      { message.user }

    it "enqueues emails for members" do
      project.members_who_get_email.length.should > 3
      project.members_who_get_email.each do |recipient|
        next if recipient == sender

        SendConversationMessageWorker.should_receive(:enqueue).with(
          :project_id                => project.id,
          :project_slug              => project.slug,
          :conversation_slug         => message.conversation.slug,
          :is_a_task                 => message.conversation.task?,
          :message_subject           => message.subject,
          :sender_name               => sender.name,
          :sender_email              => sender.email,
          :recipient_id              => recipient.id,
          :recipient_name            => recipient.name,
          :recipient_email           => recipient.email,
          :message_body              => message.body,
          :message_message_id_header => message.message_id_header,
          :message_references_header => message.references_header,
          :parent_message_id_header  => message.parent_message.try(:message_id_header),
          :reply_to                  => "#{project.name} <#{project.slug}@multifyapp.com>",
        )
      end
      MessageDispatch.new(message).enqueue
    end

    context "with options" do
      it "sends email to the sender" do
        project.members_who_get_email.each do |recipient|
          SendConversationMessageWorker.should_receive(:enqueue).with(
            hash_including( :recipient_email => recipient.email )
          )
        end

        MessageDispatch.new(message, email_sender: true).enqueue
      end

    end
  end
end
