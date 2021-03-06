class Threadable::Group < Threadable::Model

  include Threadable::Integrations::Google::Client

  self.model_name = ::Group.model_name

  def initialize threadable, group_record
    @threadable, @group_record = threadable, group_record
  end
  attr_reader :group_record

  delegate *%w{
    id
    to_param
    slug
    name
    description
    email_address_tag
    subject_tag
    color
    errors
    alias_email_address
    webhook_url
    new_record?
    persisted?
    auto_join?
    non_member_posting
    webhook_url
    google_sync?
    primary?
    private?
  }, to: :group_record

  def group_id
    group_record.id
  end

  # collections
  let(:members){ Members.new(self) }
  let(:conversations){ Conversations.new(self) }
  let(:tasks){ Tasks.new(self) }


  # scopes
  include Threadable::Conversation::Scopes
  private
  def conversations_scope
    group_record.conversations.untrashed
  end
  def tasks_scope
    group_record.tasks.untrashed
  end
  public

  def organization_record
    group_record.organization
  end

  def organization
    @organization ||= Threadable::Organization.new(threadable, organization_record)
  end

  def google_sync= sync
    organization.members.current_member.can?(:set_google_sync_for, self) or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this group'

    unless sync
      group_record.update_attributes(google_sync: false)
      return
    end

    google_client = client_for(organization.google_user)

    group_response = google_client.execute(
      api_method: directory_api.groups.get,
      parameters: {'groupKey' => alias_email_address_object.address}
    )

    if group_response.status == 404
      insert_response = google_client.execute(
        api_method: directory_api.groups.insert,
        body_object: {
          'email'       => alias_email_address_object.address,
          'name'        => "#{name} on Threadable",
          'description' => "This group enables Google Apps services sync for #{name} on Threadable / #{description}"
        }
      )

      raise Threadable::ExternalServiceError, "Creating proxy google group failed (#{insert_response.status}): #{extract_error_message(insert_response)}" unless insert_response.status == 200
    elsif group_response.status != 200
      raise Threadable::ExternalServiceError, "Searching for google group failed (#{group_response.status}): #{extract_error_message(group_response)}"
    end

    settings_response = google_client.execute(
      api_method: groups_settings_api.groups.update,
      parameters: {'groupUniqueId' => alias_email_address_object.address},
      body_object: {
        "whoCanViewMembership" => "ALL_IN_DOMAIN_CAN_VIEW",
        "whoCanViewGroup"      => "ALL_IN_DOMAIN_CAN_VIEW",
        "whoCanPostMessage"    => "ALL_IN_DOMAIN_CAN_POST",
      }
    )

    raise Threadable::ExternalServiceError, "Updating permissions for proxy google group failed (#{settings_response.status}): #{extract_error_message(settings_response)}" unless settings_response.status == 200

    group_record.update_attributes(google_sync: true)

    GoogleSyncWorker.perform_async(threadable.env, organization.id, self.id)
  end

  def email_address
    if alias_email_address.present?
      alias_email_address_object.address
    else
      "#{email_address_tag}@#{organization.email_host}"
    end
  end

  def task_email_address
    if alias_email_address.present?
      "#{alias_email_address_object.local}-task@#{alias_email_address_object.domain}"
    else
      "#{email_address_tag}+task@#{organization.email_host}"
    end
  end

  def internal_email_address
    "#{email_address_tag}@#{organization.internal_email_host}"
  end

  def internal_task_email_address
    "#{email_address_tag}+task@#{organization.internal_email_host}"
  end

  def formatted_email_address
    FormattedEmailAddress.new(
      display_name: email_address_display_name,
      address: email_address,
    ).to_s
  end

  def formatted_task_email_address
    FormattedEmailAddress.new(
      display_name: email_address_display_name(true),
      address: task_email_address,
    ).to_s
  end

  def has_webhook?
    webhook_url.present?
  end

  def update attributes
    current_member = organization.members.current_member
    current_member.can?(:change_settings_for, self) or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this group'

    if self.private? && !self.members.include?(current_member)
      current_member.can?(:change_settings_when_private_for, self) or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this group'
    end

    attributes.symbolize_keys! unless attributes.is_a? ActionController::Parameters

    if attributes[:private].present? && attributes[:private]  #present and any true value
      organization.members.current_member.can?(:make_private, self.organization.groups) or raise Threadable::AuthorizationError, 'You do not have permission to make private groups for this organization'
    end

    new_google_sync = attributes.delete(:google_sync)
    self.google_sync = new_google_sync unless new_google_sync.nil? || new_google_sync == google_sync?

    group_record.update_attributes!(attributes)
    self
  end

  def admin_update attributes
    threadable.current_user.admin? or raise Threadable::AuthorizationError, 'You do not have permission to change settings for this group'

    new_google_sync = [attributes.delete('google_sync'), attributes.delete(:google_sync)].compact.first
    self.google_sync = new_google_sync unless new_google_sync.nil? || new_google_sync == google_sync?

    group_record.update_attributes!(attributes)
    self
  end

  def destroy
    raise Threadable::AuthorizationError, 'The primary group cannot be removed' if primary?

    conversations = self.conversations.all
    if conversations.length > 0 && !organization.members.current_member.can?(:remove_non_empty_group_from, organization)
      raise Threadable::AuthorizationError, 'You are not authorized to remove groups that contain messages'
    end

    group_record.destroy
    conversations.each(&:ensure_group_membership!)
    conversations.each(&:update_group_caches!)
    self
  end

  def == other
    (self.class === other || other.class === self) && self.group_id == other.group_id
  end

  def inspect
    %(#<#{self.class} group_id: #{id.inspect}, name: #{name.inspect}>)
  end

  def reload
    group_record.reload
    self
  end

  def alias_email_address_object
    @alias_email_address_object ||= Mail::Address.new(alias_email_address)
  end

  private

  def email_address_display_name task=false
    display_name = if alias_email_address.present?
      alias_email_address_object.display_name
    else
      if organization.name == name
        name
      else
        "#{organization.name}: #{name}"
      end
    end
    display_name += " Tasks" if task && display_name
    display_name
  end
end
