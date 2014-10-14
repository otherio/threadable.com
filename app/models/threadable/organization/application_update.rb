require_dependency 'threadable/organization'

class Threadable::Organization::ApplicationUpdate < MethodObject

  OPTIONS = Class.new OptionsHash do
    required :action, :target
    optional :target_id, :payload, :user_ids
  end

  attr_reader :options, :threadable

  def call organization, options
    @threadable = organization.threadable
    @options    = OPTIONS.parse(options)

    Threadable.redis.publish(
      'application_update',
      options.merge({
        organization_id:   organization.id,
        organization_slug: organization.slug,
        created_at:        Time.now.utc.iso8601,
      }).to_json
    )

  end
end
