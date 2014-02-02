Covered.SidebarView = Ember.View.extend({

  tagName: 'nav',
  classNames: ['sidebar'],
  classNameBindings: [
    'userSettingsOpen',
    'organizationSettingsOpen',
    'otherOrganizationsOpen'
  ],

  userSettingsOpen: false,

  unbindEvents: function() {
    this.$().off('click.sidebar');
  },

  bindEvents: function() {
    var
      view         = this,
      element      = this.$(),
      controller   = this.get('controller'),
      organization = this.get('context.organization'),
      currentUser  = this.get('context.currentUser');

    this.unbindEvents();

    element.on('click.sidebar', 'li > a:first-child:not(.dont-close-sidebar)', function(e) {
      controller.send('closeSidebar');
    });

    element.on('click.sidebar', '.toggle-user-settings', function() {
      view.toggleProperty('userSettingsOpen');
    });

    element.on('click.sidebar', '.toggle-organization-settings', function() {
      view.toggleProperty('organizationSettingsOpen');
    });

    element.on('click.sidebar', '.open-other-organizations', function() {
      view.set('otherOrganizationsOpen', true);
    });

    element.on('click.sidebar', '.other-organizations a', function() {
      view.set('otherOrganizationsOpen', false);
    });

    element.on('click.sidebar', '.group .disclosure-triangle', function() {
      $(this).closest('.group').toggleClass('open');
    });
  },

  didInsertElement: function() {
    this.bindEvents();
  },

  willDestroyElement: function() {
    this.unbindEvents();
  },

  willClearRender: function() {
    this.unbindEvents();
  }


});
