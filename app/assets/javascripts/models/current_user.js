Covered.CurrentUser = RL.Model.extend({
  id:           RL.attr('string'),
  userId:       RL.attr('number'),
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
  return this.instance = this.find('current');
};

Covered.CurrentUser.reload = function(){
  if (this.instance) this.instance.reloadRecord();
};
