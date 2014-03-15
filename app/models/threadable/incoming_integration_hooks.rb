class Threadable::IncomingIntegrationHooks < Threadable::Collection

  def all
    incoming_integration_hooks_for scope.to_a
  end

  def find_by_id id
    incoming_integration_hook_for (scope.where(id: id).first or return)
  end

  def find_by_id! id
    find_by_id(id) or raise Threadable::RecordNotFound, "unable to find incoming integration hook with id #{id.inspect}"
  end

  def latest
    incoming_integration_hook_for (scope.last or return)
  end

  def create! organization, group, request, params
    # TODO: move this into a methodobject once we start dealing w/ attachments.
    # Create.call(self, params)

    provider = params['provider']

    raise Threadable::RecordNotFound("Unknown integration provider: #{provider}") unless provider == 'trello'

    incoming_integration_hook_record = ::IncomingIntegrationHook.create!(
      organization: organization.organization_record,
      group: group.group_record,
      params: params,
      provider: provider,
    )

    Threadable.after_transaction do
      ProcessIncomingIntegrationHookWorker.perform_async(threadable.env, incoming_integration_hook_record.id)
    end

    incoming_integration_hook_for incoming_integration_hook_record
  end

  def inspect
    %(#<#{self.class}>)
  end

  private

  def scope
    ::IncomingIntegrationHook.all
  end

  def incoming_integration_hook_for incoming_integration_hook_record
    Threadable::IncomingIntegrationHook.new(threadable, incoming_integration_hook_record)
  end

  def incoming_integration_hooks_for incoming_integration_hook_records
    incoming_integration_hook_records.map{ |incoming_integration_hook_record| incoming_integration_hook_for incoming_integration_hook_record }
  end

end
