Covered.GroupsView = Ember.View.extend({

  didInsertElement: function() {
    this.$('a').off('click');
    this.$('.settings, .groups-list, .bottom-nav').find('li > a').on('click', function() {
      this.get('controller').send('closeGroupsSidebar');
    }.bind(this));
  },

  willClearRender: function() {
    this.$('a').off('click');
  }

});
