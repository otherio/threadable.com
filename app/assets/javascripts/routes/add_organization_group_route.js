Covered.AddOrganizationGroupRoute = Ember.Route.extend({

  DEFAULT_COLORS: (
    '#D35400 #E74C3C #1ABC9C #34495E #8E44AD #27AE60 #3498DB #E67E22 '+
    '#2980B9 #F1C40F #9B59B6 #F39C12 #2ECC71 #2C3E50 #16A085 #C0392B'
  ).split(' '),

  availableColor: function() {
    var takenColors = this.modelFor('organization').get('groups').mapBy('color');

    return this.DEFAULT_COLORS.reduce(function(availableColor, color) {
      if (availableColor) return availableColor;
      if (takenColors.indexOf(color) === -1) return color;
    }, null);
  },

  model: function(group) {
    return Covered.Group.create({color: this.availableColor(), autoJoin: true});
  },

  renderTemplate: function() {
    this.render('add_organization_group', {into: 'organization', outlet: 'pane1'});
    this.controllerFor('organization').set('focus', 'conversations');
  },

  actions: {
    transitionToGroupMembers: function(group) {
      this.transitionTo('group_members', group.get('slug'));
    },
    transitionToGroupCompose: function(group) {
      this.transitionTo('compose_conversation', group.get('slug'));
    }
  }
});
