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
    hold_messages?
    webhook_url
    google_sync?
    primary?
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
    group_record.conversations
  end
  def tasks_scope
    group_record.tasks
  end
  public


  def organization_record
    group_record.organization
  end

  def organization
    @organization ||= Threadable::Organization.new(threadable, organization_record)
  end

  def google_sync= sync
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
      internal_email_address
    end
  end

  def task_email_address
    if alias_email_address.present?
      "#{alias_email_address_object.local}-task@#{alias_email_address_object.domain}"
    else
      internal_task_email_address
    end
  end

  def internal_email_address
    "#{organization.email_address_username}+#{email_address_tag}@#{threadable.email_host}"
  end

  def internal_task_email_address
    "#{organization.email_address_username}+#{email_address_tag}+task@#{threadable.email_host}"
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
    new_google_sync = [attributes.delete('google_sync'), attributes.delete(:google_sync)].compact.first
    self.google_sync = new_google_sync unless new_google_sync.nil? || new_google_sync == google_sync?

    group_record.update_attributes!(attributes)
    self
  end

  def destroy
    conversations = self.conversations.all

    if conversations.length > 0 && !organization.members.current_member.can?(:remove_non_empty_group_from, organization)
      raise Threadable::AuthorizationError, 'You are not authorized to remove groups that contain messages'
    end

    group_record.destroy
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

  private

  def alias_email_address_object
    @alias_email_address_object ||= Mail::Address.new(alias_email_address)
  end

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
