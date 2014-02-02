Threadable.ApplicationRoute = Ember.Route.extend({

  model: function(params) {
    return Threadable.CurrentUser.fetch();
  },

  afterModel: function(currentUser, transition) {
    Threadable.notifyPendingNotifications();
  },

  actions: {
    error: function(error, transition) {
      // console.debug('ERROR: ', error.stack, transition);
      console.debug(error.stack.toString());
    },
    willTransition: function(transition) {
      var transitions = this.controllerFor('application').get('transitions');
      transitions.unshift(transition);
      transitions.length = 2;
    },
    transitionUp: function(options){
      options = options || {};
      var currentPath = this.controllerFor('application').get('currentPath');
      currentPath = currentPath.split('.');
      currentPath.pop();
      var target = currentPath.pop();
      this.transitionTo(target);
      if (options.refresh) this.router.router.refresh();
    }
  }

});

