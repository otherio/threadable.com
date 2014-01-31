Covered.GroupSelectorComponent = Ember.Component.extend({
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
  }
});
