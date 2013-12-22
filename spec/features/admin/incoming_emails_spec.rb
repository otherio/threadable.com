require 'spec_helper'

feature "Admin incoming emails" do

  let :incoming_emails do
    15.times.map do
      covered.incoming_emails.create!(create_incoming_email_params)
    end
  end

  let :processed_incoming_emails do
    incoming_emails.sample(8).each(&:process!)
  end

  let(:columns){["Processed", "Failed", "Id", "Created at", "Recipient", "Sender", "From", "Subject", "Creator", "Organization", "Conversation", "Message"]}

  before{ processed_incoming_emails }

  def incoming_emails_table
    all('.incoming-emails-table tbody tr').map do |tr|
      values = tr.all('td').map(&:text)
      Hash[columns.zip(values)]
    end
  end

  def table_values_for incoming_emails
    incoming_emails.map do |incoming_email|
      {
        "Processed"    => incoming_email.processed? ? 'yes' : 'no',
        "Failed"       => incoming_email.processed? ? incoming_email.bounced? ? 'yes' : 'no' : '',
        "Id"           => incoming_email.id.to_s,
        "Created at"   => "less than a minute ago",
        "Recipient"    => incoming_email.recipient.truncate(25),
        "Sender"       => incoming_email.sender.truncate(25),
        "From"         => incoming_email.from.truncate(25),
        "Subject"      => incoming_email.subject.truncate(25),
        "Creator"      => incoming_email.incoming_email_record.creator_id.to_s,
        "Organization"      => incoming_email.incoming_email_record.project_id.to_s,
        "Conversation" => incoming_email.incoming_email_record.conversation_id.to_s,
        "Message"      => incoming_email.incoming_email_record.message_id.to_s,
      }
    end
  end

  scenario %(viewing incoming emails) do
    sign_in_as 'jared@other.io'
    click_on 'Admin'
    click_on 'Incoming emails'

    expect(page).to have_text 'Incoming emails page 0'
    expect(current_url).to eq admin_incoming_emails_url

    expect(incoming_emails_table).to eq table_values_for(incoming_emails.reverse[0..9])
    click_on 'next page'
    expect(incoming_emails_table).to eq table_values_for(incoming_emails.reverse[10..19])

    first('.incoming-emails-table tbody tr td a').click

    incoming_email = incoming_emails.reverse[10]

    expect(page).to have_text incoming_email.id
    expect(current_url).to eq admin_incoming_email_url(incoming_email.id)
  end
end
