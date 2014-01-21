Covered.RoutesMixin = Ember.Mixin.create({
  needs: "application",

  currentPath:      Ember.computed.alias('controllers.application.currentPath').readOnly(),
  currentRouteName: Ember.computed.alias('controllers.application.currentRouteName').readOnly(),

  router: function() {
    return Covered.__container__.lookup('router:main');
  },
  routerState: function() {
    return this.router().router.state;
  },

  organizationSlug: function() {
    try{ return this.routerState().params.organization.organization; }catch(e){}
  }.property('currentPath'),

  groupSlug: function() {
    try{ return this.routerState().params.group.group; }catch(e){}
  }.property('currentPath'),

  currentRoute: function() {
    var currentRouteName = this.get('currentRouteName');
    return Covered.Router.router.recognizer.names[currentRouteName];
  }.property('currentRouteName'),

  // returns: undefined | "conversations" | "muted_conversations" | "tasks" | "doing_tasks"
  CONVERSATIONS_ROUTES: ["conversations", "muted_conversations", "tasks", "doing_tasks"],
  conversationsRoute: function() {
    var currentPath = this.get('currentPath'), route;
    /^organization\.group\.([^.]+)/.test(currentPath);
    route = RegExp.$1;
    if (this.CONVERSATIONS_ROUTES.indexOf(route) !== -1) return route;
    return 'conversations';
  }.property('currentPath'),

  // returns: undefined | "conversation" | "muted_conversation" | "task" | "doing_task"
  conversationRoute: function() {
    var conversationsRoute = this.get('conversationsRoute');
    return conversationsRoute && conversationsRoute.slice(0,-1);
  }.property('conversationsRoute'),

  composeRoute: function() {
    var conversationRoute = this.get('conversationRoute');
    return conversationRoute && 'compose_'+conversationRoute;
  }.property('conversationRoute'),

});
