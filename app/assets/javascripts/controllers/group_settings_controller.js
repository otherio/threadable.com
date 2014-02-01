Covered.GroupSettingsController = Ember.ObjectController.extend(Covered.CurrentUserMixin, {
  needs: ['organization'],

  editableGroup: null,

  actions: {
    updateGroup: function() {
      var group = this.get('content');
      group.setProperties({
        name: this.get('editableGroup.name'),
        subjectTag: this.get('editableGroup.subjectTag'),
        color: this.get('editableGroup.color')
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
