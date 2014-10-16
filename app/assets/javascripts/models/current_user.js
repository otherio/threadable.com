Threadable.currentUserPromise = currentUserPromise;
delete this.currentUserPromise;

Threadable.CurrentUser = RL.Model.extend(Ember.Evented, {
  id:                     RL.attr('string'),
  userId:                 RL.attr('number'),
  param:                  RL.attr('string'),
  name:                   RL.attr('string'),
  emailAddress:           RL.attr('string'),
  slug:                   RL.attr('string'),
  avatarUrl:              RL.attr('string'),
  currentOrganizationId:  RL.attr('number'),
  externalAuthorizations: RL.attr('object'),
  dismissedWelcomeModal:  RL.attr('boolean'),

  organizations: RL.hasMany('Threadable.Organization'),

  applicationUpdates: RL.hasMany('Threadable.ApplicationUpdate'),

  update: function(data) {
    return $.ajax({
      type: 'PUT',
      url: '/api/users/current',
      data: {current_user: data}
    });
  },

  currentOrganization: function() {
    var
      currentOrganizationId = this.get('currentOrganizationId'),
      organizations         = this.get('organizations'),
      organization;

    if (currentOrganizationId){
      organization = organizations.findBy('id', currentOrganizationId);
    }
    if (organization) return organization;
    organization = organizations.objectAt(0);
    if (organization){
      this.set('currentOrganizationId', organization.get('id'));
      return organization;
    }
  }.property('currentOrganizationId'),

  currentOrganizationIdChanged: function() {
    this.update({current_organization_id: this.get('currentOrganizationId')});
  }.observes('currentOrganizationId'),

  authorizationFor: function(provider) {
    var authorizations = this.get('externalAuthorizations');
    if(!authorizations) { return null; }
    return authorizations.filter(function(auth) { return auth.provider == provider; })[0];
  },

  dismissWelcomeModal: function() {
    this.update({dismissed_welcome_modal: true});
  },

  triggerUpdateEvents: function() {
    var updates = this.get('applicationUpdates').filterBy('triggered', false);
    updates.forEach(function(update) {
      console.log('Received application update: ' + update.get('action') + '-' + update.get('target'));
      this.trigger(update.get('action') + '-' + update.get('target'), update);
      update.set('triggered', true);
    }.bind(this));
  }.observes('applicationUpdates.@each'),
});

Threadable.CurrentUser.reopenClass({
  resourceName: 'user',
  fetch: function() {
    if (Threadable.currentUser) return Ember.RSVP.Promise.cast(Threadable.currentUser);
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Threadable.currentUserPromise.then(function(response) {
        if (!Threadable.currentUser) Threadable.currentUser = Threadable.CurrentUser.create().deserialize(response.user);
        resolve(Threadable.currentUser);
      });
    });
  },
  reload: function(){
    // if (!Threadable.currentUser) return this.fetch();
    if (this._reloadPromise) return this._reloadPromise;
    this._reloadPromise = Threadable.currentUser.reloadRecord();
    this._reloadPromise.then(function(currentUser) {
      this._reloadPromise = null;
      return currentUser;
    }.bind(this));
    return this._reloadPromise;
  },
});

