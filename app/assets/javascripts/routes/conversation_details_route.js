Threadable.ConversationDetailRoute = Ember.Route.extend({

  parentRouteName: null,

  modelType: 'conversation',

  model: function(params){
    var organization = this.modelFor('organization');
    var conversation = this.modelFor(this.get('modelType'));

    return new Ember.RSVP.Promise(function(resolve, reject) {
      if(conversation) {
        conversation.loadDetails().catch(reject).then(function() {
          resolve(conversation);
        });
      } else {
        // conversation isn't loaded yet.
        var promise = Threadable.Conversation.fetchBySlug(organization, params.conversation);
        promise.catch(reject);
        promise.then(function(conversation) {
          conversation.loadDetails().catch(reject).then(function() {
            resolve(conversation);
          });
        });
      }
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
    this.controllerFor('topbar').set('conversationDetail', true);
    this.controllerFor('conversation').set('model', model);
    conversationDetails.set('model', model);
    conversationDetails.set('showGroupRecipients', false);
    model.set('details.organization', organization);
  },

  renderTemplate: function() {
    this.render('conversation_details', {into: 'organization', outlet: 'pane2'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  actions: {
    willTransition: function(transition) {
      this.controllerFor('organization').set('focus', 'conversations');
      this.controllerFor('topbar').set('conversationDetail', false);

      if (transition.targetName != 'conversation.index') {
        this.controllerFor('organization').set('focus', 'conversations');
      }

      $("#inputWithFocus").blur();
    }
  }

});
