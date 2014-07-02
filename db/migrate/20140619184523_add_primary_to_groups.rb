class AddPrimaryToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :primary, :boolean, default: false, null: false

    Threadable::Transactions.in_migration = true
    threadable = Threadable.new(threadable_env)

    threadable.organizations.all.each do |organization|
      puts "#{organization.name} starting"

      attributes = {
        name: organization.name,
        subject_tag: organization.subject_tag,
        email_address_tag: organization.email_address_username,
        auto_join: false,
        primary: true,
        color: '#7f8c8d',
      }

      group = organization.groups.create(attributes)

      organization.members.all.each do |member|
        next if member.organization_membership_record.ungrouped_mail_delivery == 0
        puts "    #{member.email_address}"
        membership = group.members.add member, send_notice: false
        if member.organization_membership_record.ungrouped_mail_delivery == 2
          membership.gets_in_summary!
        end
      end

      group.update(auto_join: true)

      # now move mail
      conversation_fragments = organization.conversations.ungrouped.map do |conversation|
        "(#{group.id},#{conversation.id})"
      end.join(',')

      execute "insert into conversation_groups (group_id, conversation_id) values #{conversation_fragments}"

      puts "#{organization.name} done"
    end
  end

  def down
    Threadable::Transactions.in_migration = true
    threadable = Threadable.new(threadable_env)
    Group.where(primary: true).each do |group_record|
      group = Threadable::Group.new(threadable, group_record)

      conversations = group.conversations.all

      group_record.destroy
      conversations.each(&:update_group_caches!)
      puts group.organization.name
    end

    remove_column :groups, :primary
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
