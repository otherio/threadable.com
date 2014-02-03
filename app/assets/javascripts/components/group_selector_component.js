Threadable.GroupSelectorComponent = Ember.Component.extend({
  tagName: 'span',
  classNames: ['group-selector'],
  classNameBindings: ['open'],
  open: false,

  actions: {
    toggleGroups: function() {
      this.toggleProperty('open');
    },
    addGroup: function(group) {
      this.set('open', false);
      this.get('target').send('addGroup', group);
    }
  },

  openChanged: function() {
    var view = this;
    if (this.get('open')) Ember.run.later(function() {
      view.$('.groups a:first').focus();
    });
  }.observes('open'),

  didInsertElement: function() {
    var view = this;
    $(document).on('click.GroupSelectorComponent', close);
    $(document).on('focus.GroupSelectorComponent', '*', close);
    function close(event) {
      if ($.inArray(view.$()[0], $(event.target).parents().andSelf()) !== -1) return;
      view.set('open', false);
    }
  },

  willDestroyElement: function() {
    $(document).off('.GroupSelectorComponent');
  },

});
