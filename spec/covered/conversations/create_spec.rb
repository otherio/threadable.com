require 'spec_helper'

describe Covered::Conversations::Create do

  let(:current_user){ find_user 'alice-neilson' }
  let(:project){ find_project('raceteam') }
  let(:creator){ project.members.first! }
  let(:subject){ 'i love cheese' }
  let(:body   ){ "Hey, <i>Anyone</i> want some <strong>cake</strong>?" }

  def call!
    described_class.call(
      resource: covered.conversations,
      project_slug: 'raceteam',
      subject: subject,
      body: body,
    )
  end

  it "should create a conversation" do
    conversation = call!
    expect(conversation).to be_persisted
    expect(conversation.project).to eq project
    expect(conversation.creator).to eq creator
    expect(conversation.subject).to eq subject
    expect(conversation.messages.count).to eq 1

    message = conversation.messages.first!
    expect(message.body_html).to eq body
    expect(message.conversation).to eq conversation
    expect(message.project).to eq project
  end

end
