Threadable.ConversationsRoute = Ember.Route.extend({

  conversationsScope: 'not_muted_conversations',

  setupController: function(controller, context, transition) {
    this.controllerFor('conversations').setup(this.modelFor('group'), this.conversationsScope);
    this.controllerFor('topbar').set('showingConversationsListControls', false);

    this.modelFor('application').on('create-conversation', this, this.addOrUpdateConversation);
    this.modelFor('application').on('update-conversation', this, this.addOrUpdateConversation);
  },

  renderTemplate: function() {
    this.render('conversations', {into: 'organization', outlet: 'pane1'});
  },

  addOrUpdateConversation: function(update) {
    var organization = this.modelFor('organization');
    var currentUserId = this.modelFor('application').get('userId');

    if(organization.get('id') !== update.get('organizationId')) {
      return; // some other org.
    }

    var conversationObject = update.get('payload').conversation;
    var groupSlug = this.controller.get('groupSlug');
    var scope = this.controller.get('conversationsScope');

    var conversations = this.controller.get('model');
    var existingConversation = conversations.findBy('id', conversationObject.id);

    var newConversation;

    if(existingConversation) {
      newConversation = Threadable.Conversation.create();
      newConversation.deserialize(conversationObject);

      // copy only the changed properties, but with complete deserialized objects.
      existingConversation.beginPropertyChanges();
      Object.keys(conversationObject).forEach(function(key) {
        existingConversation.set(key, newConversation.get(key));
      });
      existingConversation.endPropertyChanges();
    } else {
      // check if muted.
      if(scope == 'muted_conversations') {
        if(conversationObject.muterIds.indexOf(currentUserId) !== -1) {
          return;
        }
      }

      if(groupSlug == 'my') {
        var myGroupIds = organization.get('groups').filterBy('currentUserIsAMember', true).mapBy('id');
        if(Ember.EnumerableUtils.intersection(conversationObject.groupIds, myGroupIds).length === 0) {
          // TODO: check task vs not task, maybe
          // check if following
          if(conversationObject.followerIds.indexOf(currentUserId) == -1) {
            return; // not in the user's groups
          }
        }
      } else {
        if(conversationObject.groupIds.indexOf(organization.get('groups').findBy('slug', groupSlug)) == -1) {
          return; // not in this group
        }
      }

      newConversation = Threadable.Conversation.create();
      newConversation.deserialize(conversationObject);
      newConversation.set('organization', organization);
      conversations.unshiftObject(newConversation);
    }
  },

  willTransition: function() {
    this.modelFor('application').off('create-conversation', this.addOrUpdateConversation);
    this.modelFor('application').off('update-conversation', this.addOrUpdateConversation);
  },

  actions: {
    addConversation: function(conversation) {
      this.controller.get('model').unshiftObject(conversation);
    }
  }

});
