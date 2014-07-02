class AddPrimaryToGroups < ActiveRecord::Migration
  def up
    add_column :groups, :primary, :boolean, default: false, null: false

    Threadable::Transactions.in_migration = true
    threadable = Threadable.new(threadable_env)

    threadable.organizations.all.each do |organization|
      puts "#{organization.name} starting"

      group = organization.groups.all.find { |g| g.name == organization.name }

      if group
        group.update(auto_join: false, primary: true)
      else
        attributes = {
          name: organization.name,
          subject_tag: organization.subject_tag,
          email_address_tag: organization.email_address_username,
          auto_join: false,
          primary: true,
          color: '#7f8c8d',
        }

        group = organization.groups.create(attributes)
      end

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
      conversations_to_update = organization.conversations.ungrouped
      conversation_fragments = conversations_to_update.map do |conversation|
        "(#{group.id},#{conversation.id})"
      end.join(',')

      if conversation_fragments.present?
        execute "insert into conversation_groups (group_id, conversation_id) values #{conversation_fragments}"
      end

      conversation_ids = conversations_to_update.map(&:id).join(',')

      if conversation_ids.present?
        # with many groups
        execute "update conversations set
          groups_count = groups_count + 1,
          group_ids_cache = concat(group_ids_cache, '- #{group.id}\n') where
            id in (#{conversation_ids}) and
            group_ids_cache != '--- []\n'"

        execute "update conversations set
          groups_count = groups_count + 1,
          group_ids_cache = '---\n- #{group.id}\n' where
            id in (#{conversation_ids}) and
            group_ids_cache = '--- []\n'"

      end

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
