Threadable.ApplicationRoute = Ember.Route.extend({

  model: function(params) {
    return Threadable.CurrentUser.fetch();
  },

  afterModel: function(currentUser, transition) {
    this.set('currentUser', currentUser);
    Threadable.notifyPendingNotifications();
  },


  welcomeModalView: function() {
    this._welcomeModalView = this._welcomeModalView || Threadable.WelcomeModalView.create({
      controller: this.controller,
      container: this.container
    });
    return this._welcomeModalView;
  },

  renderTemplate: function(controller, currentUser) {
    this._super.apply(this, arguments);
    if (!currentUser.get('dismissedWelcomeModal')) this.welcomeModalView().appendTo('body');
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
    },
    dismissWelcomeModalView: function(dismissWelcomeModal) {
      this.welcomeModalView().destroy();
      delete this._welcomeModalView;
      if (dismissWelcomeModal) this.get('currentUser').dismissWelcomeModal();
    },
  }

});

