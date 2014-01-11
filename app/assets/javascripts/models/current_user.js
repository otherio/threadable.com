Covered.CurrentUser = RL.Model.extend({
  id:           RL.attr('string'),
  param:        RL.attr('string'),
  name:         RL.attr('string'),
  emailAddress: RL.attr('string'),
  slug:         RL.attr('string'),
  avatarUrl:    RL.attr('string'),
});

Covered.CurrentUser.reopenClass({
  resourceName: 'user'
});

// returns either a loaded record or a promise
Covered.CurrentUser.get = function() {
  if (this.instance) return this.instance;
  return this.fetch('current').then(this.setInstance);
};

Covered.CurrentUser.setInstance = function(instance) {
  return this.instance = instance;
}.bind(Covered.CurrentUser);
