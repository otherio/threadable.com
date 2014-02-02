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
    organization_member:        '/:organization/members/:member',
    organization_members:       '/:organization/members',
    organization_members_add:   '/:organization/members/add',
    group_member:               '/:organization/:group/members/:member',
    group_members:              '/:organization/:group/members',
    group_settings:             '/:organization/:group/settings',
    conversation:               '/:organization/:group/conversations/:conversation',
    compose_conversation:       '/:organization/:group/conversations/compose',
    conversations:              '/:organization/:group/conversations',
    muted_conversation:         '/:organization/:group/muted-conversations/:conversation',
    compose_muted_conversation: '/:organization/:group/muted-conversations/compose',
    muted_conversations:        '/:organization/:group/muted-conversations',
    task:                       '/:organization/:group/tasks/:conversation',
    compose_task:               '/:organization/:group/tasks/compose',
    tasks:                      '/:organization/:group/tasks',
    doing_task:                 '/:organization/:group/doing-tasks/:conversation',
    compose_doing_task:         '/:organization/:group/doing-tasks/compose',
    doing_tasks:                '/:organization/:group/doing-tasks',
    group:                      '/:organization/:group',
    organization:               '/:organization',
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
