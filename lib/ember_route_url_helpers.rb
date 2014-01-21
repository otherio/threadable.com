module EmberRouteUrlHelpers

  ember_routes = {
    sign_in:                        '/sign_in',
    sign_out:                       '/sign_out',
    forgot_password:                '/forgot_password',
    organization_member:            '/:organization/members/:member',
    organization_members:           '/:organization/members',
    organization_members_add:       '/:organization/members/add',
    compose_my_conversation:        '/:organization/my/conversations/compose',
    compose_my_task:                '/:organization/my/tasks/compose',
    compose_ungrouped_conversation: '/:organization/ungrouped/conversations/compose',
    compose_ungrouped_task:         '/:organization/ungrouped/tasks/compose',
    compose_group_conversation:     '/:organization/:group/conversations/compose',
    compose_group_task:             '/:organization/:group/tasks/compose',
    my_conversation:                '/:organization/my/conversations/:conversation',
    my_conversations:               '/:organization/my/conversations',
    my:                             '/:organization/my',
    ungrouped_conversation:         '/:organization/ungrouped/conversations/:conversation',
    ungrouped_conversations:        '/:organization/ungrouped/conversations',
    ungrouped:                      '/:organization/ungrouped',
    group_member:                   '/:organization/groups/:group/members/:member',
    group_members:                  '/:organization/groups/:group/members',
    group_conversation:             '/:organization/groups/:group/conversations/:conversation',
    group_conversations:            '/:organization/groups/:group/conversations',
    group:                          '/:organization/groups/:group',
    groups:                         '/:organization/groups',
    organization:                   '/:organization',
  }.freeze

  ember_routes.each do |name, pretty_path_template|
    path_template = pretty_path_template.gsub(%r</(:([^/]+))>, '/%s')

    define_method("#{name}_path") do |*args|
      options_uri = URI.parse(root_path(args.extract_options!))

      args.map! do |arg|
        case
        when arg.respond_to?(:to_param)
          arg.to_param
        when arg.respond_to?(:id)
          arg.id
        else
          arg.to_s
        end
      end

      path = begin
        path_template % args
      rescue ArgumentError
        raise ArgumentError, "the path: #{pretty_path_template.inspect} could not be generated from #{args.inspect}"
      end
      uri = URI.parse(path)
      uri.query = options_uri.query
      uri.fragment = options_uri.fragment
      uri.to_s
    end

    define_method("#{name}_url") do |*args|
      path_uri = URI.parse send("#{name}_path", *args)
      uri = URI.parse(root_url)
      uri.path = path_uri.path
      uri.query = path_uri.query
      uri.fragment = path_uri.fragment
      uri.to_s
    end
  end

end
