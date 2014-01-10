Covered.ComposeConversationRoute = Ember.Route.extend({
  target: 'conversation',

  beforeModel: function() {
    this.controllerFor('application').set('composing', this.target);
  },

  model: function() {
    // if there's an existing compose model, use it.
    var model = this.controllerFor('compose').get('model');
    var organization = this.modelFor('organization');
    if(!model || !model.get('isNew')) {
      model = this.store.createRecord('message', {
        organization: organization,
        conversation: this.store.createRecord('conversation', {
          organization: organization
        })
      });
    }
    return model;
  },

  renderTemplate: function(controller, model) {
    this.controllerFor('organization').set('focus','conversation');

    this.render('compose', {
      outlet: 'conversation',
      into: 'organization',
      controller: 'compose'
    });
  },

  actions: {
    willTransition: function(transition) {
      var target = transition.targetName;
      if(target == 'compose.task' || target == 'compose.conversation') {
        return;
      }

      this.controllerFor('application').set('composing', null);
      var model = this.get('currentModel');
      if (model.get("isNew") && !model.get("isSaving")) {
        model.rollback();
      }
    }
  },

  setupController: function(controller, model) {
    this.controllerFor('compose').set('content', model); // route & controller have different names, so this is not automatic
    this.controllerFor('compose').set('composing', this.target);
  }

});
