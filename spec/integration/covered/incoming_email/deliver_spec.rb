require 'spec_helper'

describe Covered::IncomingEmail::Deliver do

  let(:params){ ::IncomingEmail.create(params: create_incoming_email_params).params }
  let(:conversation){ double(:conversation, messages: double(:messages)) }
  let(:subject){ 'I love this community!' }
  let(:recipient){ 'raceteam@127.0.0.1' }
  let :incoming_email do
    double(:incoming_email,
      id: 879,
      incoming_email_record: double(:incoming_email_record),
      params:         params,
      subject:        subject,
      recipient:      recipient,
      creator:        double(:creator, id: 54),
      attachments:    double(:attachments),
      project:        double(:project, subject_tag: 'RaceTeam', conversations: double(:conversations), tasks: double(:tasks)),
      message_id:     double(:incoming_email_message_id),
      references:     double(:incoming_email_references),
      date:           double(:incoming_email_date, rfc2822: 'rfc2822 version of date'),
      to:             double(:incoming_email_to),
      cc:             double(:incoming_email_cc),
      parent_message: double(:incoming_email_parent_message),
      from:           double(:incoming_email_from),
      body_plain:     double(:incoming_email_body_plain),
      body_html:      double(:incoming_email_body_html),
      stripped_plain: double(:incoming_email_stripped_plain),
      stripped_html:  double(:incoming_email_stripped_html),
    )
  end
  let(:message){ double :message }

  before do
    expect(Covered).to receive(:transaction).and_yield

    params['attachment-count'].to_i.times do |i|
      expect(incoming_email.attachments).to receive(:create!).with(
        filename: params["attachment-#{i+1}"].filename,
        mimetype: params["attachment-#{i+1}"].mimetype,
        content:  params["attachment-#{i+1}"].read,
      )
    end

    expect(StripUserSpecificContentFromEmailMessageBody).to receive(:call).
      with(incoming_email.body_plain).and_return('stripped incoming_email.body_plain')
    expect(StripUserSpecificContentFromEmailMessageBody).to receive(:call).
      with(incoming_email.body_html).and_return('stripped incoming_email.body_html')
    expect(StripUserSpecificContentFromEmailMessageBody).to receive(:call).
      with(incoming_email.stripped_plain).and_return('stripped incoming_email.stripped_plain')
    expect(StripUserSpecificContentFromEmailMessageBody).to receive(:call).
      with(incoming_email.stripped_html).and_return('stripped incoming_email.stripped_html')

    expect(conversation.messages).to receive(:create!).with(
      creator_id:        54,
      message_id_header: incoming_email.message_id,
      references_header: incoming_email.references,
      date_header:       'rfc2822 version of date',
      to_header:         incoming_email.to,
      cc_header:         incoming_email.cc,
      subject:           subject[0..254],
      parent_message:    incoming_email.parent_message,
      from:              incoming_email.from,
      body_plain:        'stripped incoming_email.body_plain',
      body_html:         'stripped incoming_email.body_html',
      stripped_plain:    'stripped incoming_email.stripped_plain',
      stripped_html:     'stripped incoming_email.stripped_html',
      attachments:       incoming_email.attachments,
    ).and_return(message)

    expect(incoming_email).to receive(:message=).with(message)
    expect(incoming_email).to receive(:save!)
  end

  def call!
    described_class.call(incoming_email)
  end

  context 'when the incoming_email has a conversation' do
    before do
      incoming_email.stub conversation: conversation
      expect(incoming_email.project.conversations).to_not receive(:create!)
      expect(incoming_email.project.tasks).to_not receive(:create!)
    end
    it 'saves off the attachments, and creates a conversation message' do
      call!
    end
  end

  context 'when the incoming_email doesnt have a conversation' do
    before do
      expect(incoming_email).to receive(:conversation).once.and_return(nil)
      expect(incoming_email).to receive(:conversation=).with(conversation)
      expect(incoming_email).to receive(:conversation).once.and_return(conversation)
    end

    context 'and recipient is not a +task email address, and the subject does not contain [task] or [✔]' do
      before do
        expect(incoming_email.project.conversations).to receive(:create!).with(
          subject:    'I love this community!',
          creator_id: 54,
        ).and_return(conversation)
      end
      it 'saves off the attachments, creates a conversation and creates a conversation message' do
        call!
      end
    end
    context 'and recipient is a +task email address' do
      let(:recipient){'raceteam+task@127.0.0.1' }
      before do
        expect(incoming_email.project.tasks).to receive(:create!).with(
          subject:    'I love this community!',
          creator_id: 54,
        ).and_return(conversation)
      end
      it 'saves off the attachments, creates a task and creates a conversation message' do
        call!
      end
    end
    context 'and the subject containts [task]' do
      let(:subject){ '[task] I love this community!' }
      before do
        expect(incoming_email.project.tasks).to receive(:create!).with(
          subject:    'I love this community!',
          creator_id: 54,
        ).and_return(conversation)
      end
      it 'saves off the attachments, creates a task and creates a conversation message' do
        call!
      end
    end
    context 'and the subject containts [✔]' do
      let(:subject){ '[✔] I love this community!' }
      before do
        expect(incoming_email.project.tasks).to receive(:create!).with(
          subject:    'I love this community!',
          creator_id: 54,
        ).and_return(conversation)
      end
      it 'saves off the attachments, creates a task and creates a conversation message' do
        call!
      end
    end
    context 'and the subject is more than 255 characters' do
      let(:subject){ 'hello ' * 100 }
      before do
        expect(incoming_email.project.conversations).to receive(:create!).with(
          subject:    subject[0..254],
          creator_id: 54,
        ).and_return(conversation)
      end
      it 'saves off the attachments, creates a task and creates a conversation message' do
        call!
      end
    end

  end

end
