module EmberRouteUrlHelpers

  # How to generate these routes:
  #
  #  Step 1:
  #
  #    run this function in the javascript console:
  #
  #  !function(){
  #    var ROUTES = [];
  #    $.each(Threadable.Router.router.recognizer.names, function(name, route) {
  #      if (name === 'index') return;
  #      if (/(^|\.)(error|loading)/.test(name)) return;
  #      name = name.replace('.index', '');
  #      var segments = route.segments, path = "";
  #      for (var i=0, l=segments.length; i<l; i++) {
  #        var segment = segments[i];
  #        if ('name' in segment) {
  #          path += "/:";
  #          path += segment.name;
  #        }
  #        if ('string' in segment) {
  #          path += "/";
  #          path += segment.string;
  #        }
  #      }
  #      if (/unused_dummy/.test(path)) return;
  #      ROUTES.push([name,path]);
  #    });
  #    console.log(JSON.stringify(ROUTES));
  #  }();
  #
  #
  #  Step 2:
  #
  #     Copy the output of the previous command and then run this in your rails console:
  #
  #  JSON.parse(`pbpaste`).each{|name,path| printf("%-40s '%s',\n", "#{name}:", path) }; 1
  #
  #
  ember_routes = {
    add_group_member:                        '/:organization/:group/members/add',
    add_organization_group:                  '/:organization/add-group',
    add_organization_member:                 '/:organization/members/add',
    compose_conversation:                    '/:organization/:group/conversations/compose',
    compose_doing_task:                      '/:organization/:group/doing-tasks/compose',
    compose_muted_conversation:              '/:organization/:group/muted-conversations/compose',
    compose_task:                            '/:organization/:group/tasks/compose',
    conversation:                            '/:organization/:group/conversations/:conversation',
    conversation_detail:                     '/:organization/:group/conversations/details/:conversation',
    conversation_details:                    '/:organization/:group/conversations/details',
    conversations:                           '/:organization/:group/conversations',
    doing_task:                              '/:organization/:group/doing-tasks/:conversation',
    doing_task_detail:                       '/:organization/:group/doing-tasks/details/:conversation',
    doing_task_details:                      '/:organization/:group/doing-tasks/details',
    doing_tasks:                             '/:organization/:group/doing-tasks',
    group:                                   '/:organization/:group',
    group_member:                            '/:organization/:group/members/:member',
    group_members:                           '/:organization/:group/members',
    group_search:                            '/:organization/:group/search',
    group_search_results:                    '/:organization/:group/search/:query',
    group_settings:                          '/:organization/:group/settings',
    muted_conversation:                      '/:organization/:group/muted-conversations/:conversation',
    muted_conversation_detail:               '/:organization/:group/muted-conversations/details/:conversation',
    muted_conversation_details:              '/:organization/:group/muted-conversations/details',
    muted_conversations:                     '/:organization/:group/muted-conversations',
    organization:                            '/:organization',
    organization_member:                     '/:organization/members/:member',
    organization_members:                    '/:organization/members',
    organization_settings:                   '/:organization/settings',
    task:                                    '/:organization/:group/tasks/:conversation',
    task_detail:                             '/:organization/:group/tasks/details/:conversation',
    task_details:                            '/:organization/:group/tasks/details',
    tasks:                                   '/:organization/:group/tasks',
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

      args.map! do |arg|
        URI.encode(arg)
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
