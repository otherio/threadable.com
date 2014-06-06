class GoogleSyncWorker < Threadable::Worker
  sidekiq_options unique: true

  def perform! organization_id, group_id
    @threadable = threadable
    @organization = threadable.organizations.find_by_id(organization_id) or return
    @group = organization.groups.find_by_id(group_id) or return

    sync_members!
  end

  attr_reader :email, :params, :organization, :conversation

  private

  def sync_members!
    Threadable::Integrations::Google::GroupMembersSync.call(threadable, @group)
  end
end
