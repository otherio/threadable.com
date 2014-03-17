class Threadable::User::MergeInto < MethodObject

  def call user, destination_user
    @user, @destination_user = user, destination_user
    @user_record = @user.user_record
    @destination_user_id = @destination_user.id
    @Threadable = user.threadable
    Threadable.transaction do
      move_email_addresses!
      move_organization_memberships!
      move_group_memberships!
      move_messages!
      move_events!
      move_external_authorizations!
      move_task_doers!
      destroy_user!
    end
    @user
  end

  def move_email_addresses!
    @user_record.email_addresses.update_all(user_id: @destination_user_id, primary: false)
  end

  def move_organization_memberships!
    @user_record.organization_memberships.find_each(batch_size:10) do |organization_membership|
      begin
        organization_membership.update(user_id: @destination_user_id)
      rescue PG::UniqueViolation
      end
    end
  end

  def move_group_memberships!
    @user_record.group_memberships.find_each do |group_membership|
      begin
        group_membership.update(user_id: @destination_user_id)
      rescue PG::UniqueViolation
      end
    end
  end

  def move_messages!
    @user_record.messages.update_all(user_id: @destination_user_id)
  end

  def move_events!
    @user_record.events.update_all(user_id: @destination_user_id)
    # go though each event updating the serialized content hash
    Event.find_each do |event|
      if event.content[:doer_id] && event.content[:doer_id] == @user.id
        event.content[:doer_id] = @destination_user_id
        event.save!
      end
    end
  end

  def move_external_authorizations!
    @user_record.external_authorizations.find_each do |external_authorization|
      begin
        external_authorization.update(user_id: @destination_user_id)
      rescue PG::UniqueViolation
      end
    end
  end

  def move_task_doers!
    @user_record.task_doers.find_each do |task_doer|
      begin
        task_doer.update(user_id: @destination_user_id)
      rescue PG::UniqueViolation
      end
    end
  end

  def destroy_user!
    User.find(@user_record.id).destroy!
  end

end
