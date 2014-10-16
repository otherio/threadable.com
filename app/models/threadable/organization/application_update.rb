require_dependency 'threadable/organization'

class Threadable::Organization::ApplicationUpdate < MethodObject

  include SerializerConcern

  OPTIONS = Class.new OptionsHash do
    required :action, :target
    optional :target_id, :payload, :user_ids, :target_record, :serializer
  end

  attr_reader :options, :threadable

  def call organization, options
    @threadable = organization.threadable
    @options    = OPTIONS.parse(options)

    if options[:target_record]
      serializer = options[:serializer] || options[:target].to_s.pluralize
      payload = serialize(serializer, options[:target_record])
    else
      payload = options[:payload]
    end

    Threadable.redis.publish(
      'application_update',
      {
        action:            options[:action],
        target:            options[:target],
        target_id:         options[:target_record].try(:id) || options[:target_id],
        payload:           payload,
        user_ids:          options[:user_ids],
        organization_id:   organization.id,
        organization_slug: organization.slug,
        created_at:        Time.now.utc.iso8601,
      }.to_json
    )
  end
end
