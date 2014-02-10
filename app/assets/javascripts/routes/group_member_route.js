Threadable.GroupMemberRoute = Ember.Route.extend({

  model: function(params){
    return this.modelFor('group_members').get('members').findBy('slug', params.member);
  },

  renderTemplate: function() {
    this.render('group_member', {into: 'organization', outlet: 'pane2'});
  },

});
