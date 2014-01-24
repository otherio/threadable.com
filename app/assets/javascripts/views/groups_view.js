Covered.GroupsView = Ember.View.extend({

  didInsertElement: function() {
    this.$('a').off('click');
    this.$('.settings, .groups-list, .bottom-nav').find('li > a').on('click', function(e) {
      if(! $(e.currentTarget).hasClass('keep-sidebar-open')) {
        this.get('controller').send('closeGroupsSidebar');
      }
    }.bind(this));

    var organization = this.get('context.organization');
    var currentUser = this.get('context.currentUser');

    UserVoice.push(['identify', {
      email:      currentUser.get('emailAddress'),
      name:       currentUser.get('name'),
      id:         currentUser.get('id'),
      account: {
        id:       organization.get('id'),
        name:     organization.get('name'),
      }
    }]);

    UserVoice.push(['addTrigger', '#feedback-button', {
      mode: 'contact'
    }]);

  },

  willClearRender: function() {
    this.$('a').off('click');
  }

});
