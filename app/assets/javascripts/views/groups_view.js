Covered.GroupsView = Ember.View.extend({

  didInsertElement: function() {
    var
      controller   = this.get('controller'),
      organization = this.get('context.organization'),
      currentUser  = this.get('context.currentUser');

    this.$('a').off('click.closeGroupsSidebar');

    this.$('a:not(.keep-sidebar-open)').on('click.closeGroupsSidebar', function(e) {
      controller.send('closeGroupsSidebar');
    });


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
    this.$('a').off('click.closeGroupsSidebar');
  }

});
