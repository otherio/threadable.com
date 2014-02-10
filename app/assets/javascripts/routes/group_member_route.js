Threadable.GroupMemberRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('group_members').get('members').findBy('slug', params.member);
  },

  redirect: function(member, transition) {
    if (member) return this._super.apply(this, arguments);
    this.transitionTo('group_members');
  },

  renderTemplate: function() {
    this.render('group_member', {into: 'organization', outlet: 'pane2'});
  },

});
