Covered.currentUserPromise = currentUserPromise;
delete this.currentUserPromise;

Covered.CurrentUser = RL.Model.extend({
  id:           RL.attr('string'),
  userId:       RL.attr('number'),
  param:        RL.attr('string'),
  name:         RL.attr('string'),
  emailAddress: RL.attr('string'),
  slug:         RL.attr('string'),
  avatarUrl:    RL.attr('string'),

  organizations: RL.hasMany('Covered.Organization'),
});

Covered.CurrentUser.reopenClass({
  resourceName: 'user',
  fetch: function() {
    if (Covered.currentUser) return Ember.RSVP.Promise.cast(Covered.currentUser);
    return new Ember.RSVP.Promise(function(resolve, reject) {
      Covered.currentUserPromise.then(function(response) {
        if (!Covered.currentUser) Covered.currentUser = Covered.CurrentUser.create().deserialize(response.user);
        resolve(Covered.currentUser);
      });
    });
  },
  reload: function(){
    // if (!Covered.currentUser) return this.fetch();
    if (this._reloadPromise) return this._reloadPromise;
    this._reloadPromise = Covered.currentUser.reloadRecord();
    this._reloadPromise.then(function(currentUser) {
      this._reloadPromise = null;
      return currentUser;
    }.bind(this));
    return this._reloadPromise;
  }
});
