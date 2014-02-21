Threadable.ConversationRoute = Ember.Route.extend({

  parentRouteName: null,

  model: function(params){
    var organization = this.modelFor('organization');

    return new Ember.RSVP.Promise(function(resolve, reject) {
      var promise = Threadable.Conversation.fetchBySlug(organization, params.conversation);
      promise.catch(reject);
      promise.then(function(conversation) {
        conversation.loadEvents().catch(reject).then(function() {
          resolve(conversation);
        });
      });
    });
  },

  afterModel: function(conversation, transition) {
    if (conversation) return;
    transition.abort();
    this.transitionTo(this.get('parentRouteName'),
      transition.state.params.organization.organization,
      transition.state.params.group.group
    );
  },

  setupController: function(controller, model) {
    this._super(controller, model);
    this.controllerFor('conversation').set('model', model)
    this.controllerFor('reply').set('model', Threadable.Message.create({}));
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'pane2'});
    this.render('reply', {into: 'conversation', outlet: 'reply'});
    this.render('doerSelector', {into: 'conversation', outlet: 'doerSelector'});
    this.render('pendingDoers', {into: 'reply', outlet: 'pendingDoers'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function(transition) {
      this.controllerFor('organization').set('focus', 'conversations');
      $("#inputWithFocus").blur();
    }
  }

});
