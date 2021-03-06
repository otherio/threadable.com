Threadable.SidebarView = Ember.View.extend({

  tagName: 'nav',
  classNames: ['sidebar'],
  classNameBindings: [
    'userSettingsOpen',
    'organizationControlsOpen',
    'otherOrganizationsOpen'
  ],

  userSettingsOpen: false,
  organizationControlsOpen: false,
  otherOrganizationsOpen: false,

  unbindEvents: function() {
    this.$().off('.sidebar');
    $(document).off('.close-other-organizations');
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

    element.on('click.sidebar', '.toggle-organization-controls', function() {
      view.toggleProperty('organizationControlsOpen');
    });

    element.on('click.sidebar', '.open-other-organizations', function() {
      view.set('otherOrganizationsOpen', true);
    });

    element.on('click.sidebar', '.other-organizations a', function() {
      view.set('otherOrganizationsOpen', false);
    });

    element.on('click.sidebar', '.group', function() {
      var group = $(this).closest('.group');
      element.find('.group.open').not(group).removeClass('open');
      group.addClass('open');
    });

    element.on('click.sidebar', '.group .disclosure-triangle', function(event) {
      event.preventDefault();
      event.stopImmediatePropagation();
      $(this).closest('.group').toggleClass('open');
    });
  },

  otherOrganizationsChanged: function() {
    var view = this;
    if (view.get('otherOrganizationsOpen')){
      Ember.run.later(function() {
        $(document).on('click.close-other-organizations', function(event) {
          if ($(event.target).closest('.other-organizations').length) return;
          view.set('otherOrganizationsOpen', false);
        });
        $(document).on('keydown.close-other-organizations', function(event) {
          if (event.which === 27) view.set('otherOrganizationsOpen', false);
        });
      });
    }else{
      $(document).off('.close-other-organizations');
    }
  }.observes('otherOrganizationsOpen'),

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
