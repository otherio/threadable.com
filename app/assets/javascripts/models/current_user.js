Covered.CurrentUser = RL.Model.extend({
  id:           RL.attr('string'),
  userId:       RL.attr('number'),
  param:        RL.attr('string'),
  name:         RL.attr('string'),
  emailAddress: RL.attr('string'),
  slug:         RL.attr('string'),
  avatarUrl:    RL.attr('string'),

  organizations: RL.hasMany('Covered.Organization'),

  isSignedIn: function() { return !!this.get('userId'); }.property('userId')

});

Covered.CurrentUser.reopenClass({
  resourceName: 'user',
  instance: null,
  fetch: function() {
    this.promise || (this.promise = this._super('current').then(
      function(instance) { return this.instance = instance; }.bind(this),
      function(instance) { return this.instance = null;     }.bind(this)
    ));
    return this.promise;
  },
  reload: function(){
    if (this.instance){
      return this.promise = this.instance.reloadRecord();
    }else{
      return this.fetch();
    }
  },
  signOut: function() {
    this.instance.setProperties({
      userId:        null,
      param:         null,
      name:          null,
      emailAddress:  null,
      slug:          null,
      avatarUrl:     null,
      organizations: null,
    });
    return $.post('/sign_out.json');
  }
});
