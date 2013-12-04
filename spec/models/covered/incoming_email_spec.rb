require 'spec_helper'

describe Covered::IncomingEmail do

  let :incoming_email_record do
    double(:incoming_email_record,
      id:       9883,
      primary?: true,
    )
  end
  let(:incoming_email){ described_class.new(covered, incoming_email_record) }
  subject{ incoming_email }

  it{ should have_constant :Creator }
  it{ should have_constant :Attachments }

  it { should delegate(:id                ).to(:incoming_email_record) }
  it { should delegate(:to_param          ).to(:incoming_email_record) }
  it { should delegate(:params            ).to(:incoming_email_record) }
  it { should delegate(:creator_id        ).to(:incoming_email_record) }
  it { should delegate(:creator_id=       ).to(:incoming_email_record) }
  it { should delegate(:project_id        ).to(:incoming_email_record) }
  it { should delegate(:project_id=       ).to(:incoming_email_record) }
  it { should delegate(:conversation_id   ).to(:incoming_email_record) }
  it { should delegate(:conversation_id=  ).to(:incoming_email_record) }
  it { should delegate(:message_id        ).to(:incoming_email_record) }
  it { should delegate(:message_id=       ).to(:incoming_email_record) }
  it { should delegate(:parent_message_id ).to(:incoming_email_record) }
  it { should delegate(:parent_message_id=).to(:incoming_email_record) }
  it { should delegate(:message_id        ).to(:incoming_email_record) }
  it { should delegate(:message_id=       ).to(:incoming_email_record) }
  it { should delegate(:created_at        ).to(:incoming_email_record) }


end
