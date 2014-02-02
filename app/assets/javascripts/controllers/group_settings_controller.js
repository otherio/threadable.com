Threadable.GroupSettingsController = Ember.ObjectController.extend(Threadable.CurrentUserMixin, {
  needs: ['organization'],

  editableGroup: function() { return this.get('model').copy(); }.property('model'),

  actions: {
    updateGroup: function() {
      var group = this.get('content');
      group.setProperties({
        subjectTag: this.get('editableGroup.subjectTag'),
        color:      this.get('editableGroup.color'),
        autoJoin:   this.get('editableGroup.autoJoin')
      });

      group.saveRecord().then(
        groupSaved.bind(this),
        error.bind(this)
      );

      function groupSaved(response) {
        group.deserialize(response.group);
        this.send('transitionToGroup', group);
      }

      function error(response) {
        var error = response && response.error || 'an unknown error occurred';
        this.set('error', error);
      }
    }
  }

});
