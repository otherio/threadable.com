require 'spec_helper'

include SerializerConcern

describe Threadable::Organization::ApplicationUpdate, :type => :request do
  let(:organization) { threadable.organizations.find_by_slug('raceteam') }
  let(:member) { organization.members.find_by_email_address('tom@ucsd.example.com') }
  let(:self_member) { organization.members.find_by_email_address('bethany@ucsd.example.com') }

  before do
    sign_in_as 'bethany@ucsd.example.com'
    Timecop.freeze
  end

  it 'publishes the app update to redis' do
    expect(Threadable.redis).to receive(:publish).with(
      'application_update',
      {
        action:            'create',
        target:            'message',
        target_id:         15,
        payload:           {conversation_id: 105},
        user_ids:          [10, 16],
        organization_id:   organization.id,
        organization_slug: organization.slug,
        created_at:        Time.now.utc.iso8601,
      }.to_json
    )

    described_class.call(
      organization,
      action:    'create',
      target:    'message',
      target_id: 15,
      payload:   {conversation_id: 105},
      user_ids:  [10, 16]
    )
  end

  context 'with a record specified' do
    let(:message){organization.conversations.all.first.messages.all.first}

    it 'publishes the app update to redis' do
      expect(Threadable.redis).to receive(:publish).with(
        'application_update',
        {
          action:            :create,
          target:            :message,
          target_id:         message.id,
          payload:           serialize_model(:messages, message),
          user_ids:          [10, 16],
          organization_id:   organization.id,
          organization_slug: organization.slug,
          created_at:        Time.now.utc.iso8601,
        }.to_json
      )

      described_class.call(
        organization,
        action:        :create,
        target:        :message,
        target_record: message,
        user_ids:      [10, 16]
      )
    end

  end
end
