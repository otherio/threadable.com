// This is a base class. We should never actually endup here
Covered.ConversationRoute = Ember.Route.extend({

  parentRouteName: null,

  model: function(params){
    var conversations, conversation;

    conversations = this.modelFor(this.get('parentRouteName'));
    if (conversations && conversations.isLoaded){
      conversation = conversations.findBy('slug', params.conversation);
      if (conversation) conversation.loadEvents();
    }else{
      conversations = Covered.Conversation.fetch({
        slug: params.conversation,
        organization_id: this.modelFor('organization').get('slug'),
      });
    }
    return conversation;
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
    this.controllerFor('conversation').set('model', model);
    this.controllerFor('reply').set('model', Covered.Message.create({}));
    this.controllerFor('doerSelector').set('model', this.controllerFor('organization').get('members'));
    var doers = model && model.get('doers');
    if (doers) this.controllerFor('doerSelector').set('doers', doers.toArray());
    this.controllerFor('pendingDoers').set('model', this.controllerFor('doerSelector'));
  },

  renderTemplate: function() {
    this.render('conversation', {into: 'organization', outlet: 'conversationPane'});
    this.render('reply', {into: 'conversation', outlet: 'reply'});
    this.render('doerSelector', {into: 'conversation', outlet: 'doerSelector'});
    this.render('pendingDoers', {into: 'reply', outlet: 'pendingDoers'});
    this.controllerFor('organization').set('focus', 'conversation');
  },

  // actions: {
  //   willTransition: function(transition) {
  //     // this.controllerFor('conversation').set('model', null);
  //   }
  // }

});
