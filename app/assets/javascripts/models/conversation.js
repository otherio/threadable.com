Threadable.Conversation = RL.Model.extend({
  id:                RL.attr('number'),
  organizationSlug:  RL.attr('string'),
  slug:              RL.attr('string'),
  subject:           RL.attr('string'),
  task:              RL.attr('boolean'),
  createdAt:         RL.attr('date'),
  updatedAt:         RL.attr('date'),
  lastMessageAt:     RL.attr('date'),
  participantNames:  RL.attr('array'),
  numberOfMessages:  RL.attr('number'),
  messageSummary:    RL.attr('string'),
  groupIds:          RL.attr('array'),

  organizationId:    RL.attr('string'),
  doers:             RL.hasMany('Threadable.OrganizationMember'),
  done:              RL.attr('boolean'),
  muted:             RL.attr('boolean'),
  followed:          RL.attr('boolean'),
  trashed:           RL.attr('boolean'),
  trashedAt:         RL.attr('date'),
  position:          RL.attr('number'),

  isTask:     Ember.computed.alias('task'),
  isDone:     Ember.computed.alias('done'),
  isMuted:    Ember.computed.alias('muted'),
  isFollowed: Ember.computed.alias('followed'),
  isTrashed:  Ember.computed.alias('trashed'),

  loadEvents: RL.loadAssociationMethod('events', function(conversation){
    return Threadable.Event.fetch({
      organization_id: conversation.get('organizationSlug'),
      conversation_id: conversation.get('slug')
    });
  }),

  loadDetails: RL.loadAssociationMethod('details', function(conversation){
    return Threadable.ConversationDetail.fetch({
      organization_id: conversation.get('organizationSlug'),
      slug: conversation.get('slug')
    });
  }.bind(this)),

  hasMessages: function() {
    return this.get('numberOfMessages') > 0;
  }.property('numberOfMessages'),

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
    }).sortBy('name');
  }.property('groupIds','organization.groups'),

  myTask: function() {
    if (!this.get('isTask')) return false;
    var userId = Threadable.currentUser.get('userId');
    var doers = this.get('doers');
    if (!doers) return false;
    var userIds = doers.mapBy('userId');
    return userIds.indexOf(userId) !== -1;
  }.property('isTask', 'doers'),

  currentUserIsInGroups: function() {
    return !! this.get('groups').findBy('currentUserIsAMember', true);
  }.property('groupIds'),

  currentUserIsARecipient: function() {
    if(this.get('isFollowed')) return true;
    if(this.get('isMuted')) return false;
    if(this.get('currentUserIsInGroups')) return true;
  }.property('currentUserIsInGroups', 'isFollowed', 'isMuted')

});

Threadable.RESTAdapter.map("Threadable.Conversation", {
  primaryKey: "slug"
});


Threadable.Conversation.reopen(Threadable.AddOrganizationIdToRequestsMixin);

Threadable.Conversation.reopenClass({

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

  fetchPageByGroupAndScope: function(organization, groupSlug, scope, page) {
    var setOrganizationAndStoreInCache = this._setOrganizationAndStoreInCache.bind(this);
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Threadable.Conversation.fetch({
        organization: organization.get('slug'),
        group: groupSlug,
        scope: scope,
        page: page,
      }).then(
        function(conversations) {
          conversations = conversations.constructor.create({
            content: conversations.map(function(conversation) {
              return setOrganizationAndStoreInCache(organization, conversation);
            })
          });
          resolve(conversations);
        },
        function(reason) {
          reject(reason);
        }
      );
    });
  }

});
