require 'spec_helper'

describe "posting incoming emails" do

  let :params do
    create_incoming_email_params(
      recipient:     recipient,
      sender:        sender,
      from:          sender,
      envelope_from: sender,
      in_reply_to:   in_reply_to,
      references:    references,
    )
  end

  let(:recipient  ){ 'catplayland@127.0.0.1' }
  let(:sender     ){ 'kitty@catplayland.net' }
  let(:in_reply_to){ "" }
  let(:references ){ "" }


  shared_context 'the project is not found' do
    let(:recipient) { 'poopfarm@127.0.0.1' }
  end

  shared_context 'the project is found' do
    let(:recipient) { 'raceteam@127.0.0.1' }
  end

  shared_context 'the sender is not a member' do
    let(:sender) { 'alfred@batman.ca' }
  end

  shared_context 'the sender is a member' do
    let(:sender) { 'alice@ucsd.covered.io' }
  end

  shared_context 'the message is a new conversation' do
    let(:in_reply_to) { "" }
    let(:references ) { "" }
  end

  shared_context 'the message is a reply' do
    let(:project    ) { covered.projects.find_by_slug! 'raceteam' }
    let(:in_reply_to) { project.messages.latest.message_id_header }
    let(:references ) { in_reply_to }
  end


  shared_examples 'the message is accepted' do
    it 'renders a 200' do
      post emails_path, params
      expect(response.status).to eq 200
      expect(response.body).to be_blank
    end
  end

  shared_examples 'the message is rejected' do
    it 'renders a 406' do
      post emails_path, params
      expect(response.status).to eq 406
      expect(response.body).to be_blank
    end
  end


  context 'when the project is not found' do
    include_context  'the project is not found'
    include_examples 'the message is rejected'
  end

  context 'when the project is found' do
    include_context  'the project is found'

    context 'and the sender is not a member' do
      include_context  'the sender is not a member'

      context 'and the message starts a new conversation' do
        include_context  'the message is a new conversation'
        include_examples 'the message is rejected'
      end

      context 'when the message is a reply' do
        include_context  'the message is a reply'
        include_examples 'the message is accepted'
      end
    end

    context 'when the sender is a member' do
      include_context  'the sender is a member'

      context 'when the message starts a new conversation' do
        include_context  'the message is a new conversation'
        include_examples 'the message is accepted'
      end

      context 'when the message is a reply' do
        include_context  'the message is a reply'
        include_examples 'the message is accepted'
      end
    end
  end

end
