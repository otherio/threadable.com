class AddTombstoneForMultiGroupConversations < ActiveRecord::Migration
  def up
    Threadable::Transactions.in_migration = true
    threadable = Threadable.new(threadable_env)

    threadable.organizations.all.each do |organization|
      primary_group = organization.groups.primary

      organization.conversations.all_with_multiple_groups.each do |conversation|
        unless conversation.groups.all.find{|g| g.primary? }
          conversation_groups = conversation.conversation_record.conversation_groups
          conversation_groups << conversation_groups.new(group_id: primary_group.id, active: false)
          puts conversation.subject
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  def threadable_env
    {
      host:     Rails.application.config.default_host,
      port:     Rails.application.config.default_port,
      protocol: Rails.application.config.default_protocol,
      worker:   true,
    }
  end
end
