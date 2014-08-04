class AddSentEmailRecordsForMessageCreators < ActiveRecord::Migration
  def up
    # this creates sent_email records for the message creator on all old messages.
    execute "insert into sent_emails (message_id, user_id, email_address_id, created_at)
      select
        messages.id as message_id,
        messages.user_id,
        email_addresses.id as email_address_id,
        now() as created_at
      from
        email_addresses,
        messages left join sent_emails on sent_emails.message_id = messages.id and sent_emails.user_id = messages.user_id
      where
        messages.user_id is not null and
        messages.user_id = email_addresses.user_id and
        email_addresses.primary = true and
        sent_emails.id is null"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
