Threadable.ConversationDetailsRoute = Ember.Route.extend({

  parentRouteName: null,

  model: function(params){
    var conversation = this.modelFor('conversation');

    return new Ember.RSVP.Promise(function(resolve, reject) {
      conversation.loadDetails().catch(reject).then(function() {
        resolve(conversation);
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
    var conversationDetails = this.controllerFor('conversationDetails');
    var organization = this.controllerFor('organization');
    this._super(controller, model);
    conversationDetails.set('model', model);
    model.set('details.organization', organization);
  },

  renderTemplate: function() {
    this.render('conversation_details', {into: 'organization', outlet: 'pane2'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function(transition) {
      this.controllerFor('organization').set('focus', 'conversations');

      debugger;
      if (transition.targetName != 'conversation.index') {
        this.controllerFor('organization').set('focus', 'conversations');
      }

      $("#inputWithFocus").blur();
    }
  }

});
