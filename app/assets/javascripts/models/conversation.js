Covered.Conversation = RL.Model.extend({
  id:                RL.attr('number'),
  organizationSlug:  RL.attr('string'),
  slug:              RL.attr('string'),
  subject:           RL.attr('string'),
  task:              RL.attr('boolean'),
  createdAt:         RL.attr('date'),
  updatedAt:         RL.attr('date'),
  participantNames:  RL.attr('array'),
  numberOfMessages:  RL.attr('number'),
  messageSummary:    RL.attr('string'),
  groupIds:          RL.attr('array'),
  organizationId:    RL.attr('string'),
  doers:             RL.hasMany('Covered.Member'),
  done:              RL.attr('boolean'),
  muted:             RL.attr('boolean'),

  isTask:  Ember.computed.alias('task'),
  isDone:  Ember.computed.alias('done'),
  isMuted: Ember.computed.alias('muted'),

  hasMessages: function() {
    return this.get('numberOfMessages') > 0;
  }.property('numberOfMessages'),

  loadEvents: RL.loadAssociationMethod('events', function(conversation){
    return Covered.Event.fetch({
      organization_id: conversation.get('organizationSlug'),
      conversation_id: conversation.get('slug')
    });
  }),

  participantNamesString: function() {
    return this.get('participantNames').join(', ');
  }.property('participantNames'),

  groups: function() {
    var groups = this.get('organization.groups');
    if (typeof groups === 'undefined') throw new Error('no groups. did you forget to set organization?');
    var groupIds = this.get('groupIds');
    if (!groupIds) return [];
    return groups.filter(function(group) {
      return groupIds.indexOf(group.get('id')) > -1;
    });
  }.property('groupIds','organization.groups'),


  myTask: function() {
    if (!this.get('isTask')) return false;
    var userId = Covered.currentUser.get('userId');
    var doers = this.get('doers');
    if (!doers) return false;
    var userIds = doers.mapBy('userId');
    return userIds.indexOf(userId) !== -1;
  }.property('isTask', 'doers')
});

Covered.RESTAdapter.map("Covered.Conversation", {
  primaryKey: "slug"
});


Covered.Conversation.reopen(Covered.AddOrganizationIdToRequestsMixin);

Covered.Conversation.reopenClass({

  _cacheBySlug: {},

  getCache: function(organizationSlug) {
    var _cacheBySlug = this._cacheBySlug;
    return _cacheBySlug[organizationSlug] || (_cacheBySlug[organizationSlug] = {});
  },

  getCached: function(organizationSlug, conversation_slug) {
    return this.getCache(organizationSlug)[conversation_slug];
  },

  cache: function(conversation) {
    var
      organizationSlug   = conversation.get('organizationSlug'),
      conversationSlug   = conversation.get('slug'),
      cache              = this.getCache(organizationSlug),
      cachedConversation = cache[conversationSlug];

    if (cachedConversation){
      cachedConversation.deserialize(conversation.serialize()['conversation']);
      return cachedConversation;
    }else{
      cache[conversationSlug] = conversation;
      return conversation;
    }
  },

  _setOrganizationAndStoreInCache: function(organization, conversation){
    conversation.set('organization', organization);
    return this.cache(conversation);
  },

  fetchBySlug: function(organization, conversation_slug) {
    var organizationSlug = organization.get('slug');
    var conversation = this.getCached(organizationSlug, conversation_slug);
    if (conversation) return Ember.RSVP.Promise.cast(conversation);
    var setOrganizationAndStoreInCache = this._setOrganizationAndStoreInCache.bind(this);
    var promise = this.fetch({
      organization_id: organizationSlug,
      slug: conversation_slug,
    });
    promise.then(function(conversation) {
      setOrganizationAndStoreInCache(organization, conversation);
    });
    return promise;
  },

  _fetch: function(organization, context, scope, group_slug) {
    var
      promise,
      organizationSlug = organization.get('slug'),
      setOrganizationAndStoreInCache = this._setOrganizationAndStoreInCache.bind(this);

    promise = this.fetch({
      organization_id: organizationSlug,
      context: context,
      scope: scope,
      group_id: group_slug
    });

    promise.then(function(conversations) {
      return conversations.map(function(conversation) {
        return setOrganizationAndStoreInCache(organization, conversation);
      });
    });

    return promise;
  },

  myNotMutedConversations: function(organization) {
    return this._fetch(organization, 'my', 'not_muted_conversations');
  },
  myMutedConversations: function(organization) {
    return this._fetch(organization, 'my', 'muted_conversations');
  },
  myAllTask: function(organization) {
    return this._fetch(organization, 'my', 'all_task');
  },
  myDoingTasks: function(organization) {
    return this._fetch(organization, 'my', 'doing_tasks');
  },
  ungroupedNotMutedConversations: function(organization) {
    return this._fetch(organization, 'ungrouped', 'not_muted_conversations');
  },
  ungroupedMutedConversations: function(organization) {
    return this._fetch(organization, 'ungrouped', 'muted_conversations');
  },
  ungroupedAllTask: function(organization) {
    return this._fetch(organization, 'ungrouped', 'all_task');
  },
  ungroupedDoingTasks: function(organization) {
    return this._fetch(organization, 'ungrouped', 'doing_tasks');
  },
  groupNotMutedConversations: function(organization, group_slug) {
    return this._fetch(organization, 'group', 'not_muted_conversations', group_slug);
  },
  groupMutedConversations: function(organization, group_slug) {
    return this._fetch(organization, 'group', 'muted_conversations', group_slug);
  },
  groupAllTask: function(organization, group_slug) {
    return this._fetch(organization, 'group', 'all_task', group_slug);
  },
  groupDoingTasks: function(organization, group_slug) {
    return this._fetch(organization, 'group', 'doing_tasks', group_slug);
  },

});
