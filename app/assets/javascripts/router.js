// For more information see: http://emberjs.com/guides/routing/

Threadable.Router.reopen({
  location: 'history'
});

Threadable.Router.map(function() {

  this.resource('organization', {path: '/:organization'}, function(){
    this.resource('organization_settings', {path: '/settings'});
    this.resource('add_organization_group', {path: '/add-group'});
    this.resource('organization_members', {path: '/members'}, function(){
      this.resource('organization_member', {path: '/:member'});
      this.resource('add_organization_member', {path: '/add'});
    });

    this.resource('group', {path: '/:group'}, function(){
      this.resource('group_members', {path: '/members'}, function(){
        this.resource('group_member', {path: '/:member'});
        this.resource('add_group_member', {path: '/add'});
      });
      this.resource('group_settings', {path: '/settings'});
      this.resource('group_delivery_options', {path: '/delivery-options'});
      this.resource('group_search', {path: '/search'}, function() {
        this.resource('group_search_results', {path: '/:query'});
      });
      this.resource('conversations', {path: '/conversations'}, function(){
        conversationRoutes.call(this, 'conversation');
      });
      this.resource('muted_conversations', {path: '/muted-conversations'}, function(){
        conversationRoutes.call(this, 'muted_conversation');
      });
      this.resource('tasks', {path: '/tasks'}, function(){
        conversationRoutes.call(this, 'task');
      });
      this.resource('doing_tasks', {path: '/doing-tasks'}, function(){
        conversationRoutes.call(this, 'doing_task');
      });
    });
  });

  this.route("not_found", { path: "*path"});

  function conversationRoutes(scope, param) {
    this.resource(scope+'_details', {path: '/details'}, function(){
      this.resource(scope+'_detail', {path: '/:conversation'});
    });

    this.resource(scope, {path: '/:conversation'});
    this.resource('compose_'+scope, {path: '/compose'});
  }

});
