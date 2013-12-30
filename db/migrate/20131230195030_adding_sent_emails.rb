class AddingSentEmails < ActiveRecord::Migration
  def up
    # DUN DUN DUUUUNNNNN!
    create_table :sent_emails do |t|
      t.integer :message_id
      t.integer :user_id
      t.integer :email_address_id
      t.datetime :created_at
    end
    add_index :sent_emails, [:message_id, :user_id], unique: true

    Organization.find_each do |organization|
      members = organization.members.includes(:email_addresses).map do |member|
        [member.id, member.email_addresses.primary.first.id]
      end

      organization.messages.find_each do |message|
        members.each do |user_id, email_address_id|
          SentEmail.create!(message_id: message.id, user_id: user_id, email_address_id: email_address_id)
        end
      end
    end
  end

  def down
    drop_table :sent_emails
  end
end
