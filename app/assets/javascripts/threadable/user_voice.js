Threadable.setupUserVoice = function(currentUser, organization) {
  Ember.run.later(function() {
    if (!this.UserVoice || !this.UserVoice.push) return;

    UserVoice.push(['identify', {
      email:      Threadable.currentUser.get('emailAddress'),
      name:       Threadable.currentUser.get('name'),
      id:         Threadable.currentUser.get('id'),
      account: {
        id:       organization.get('id'),
        name:     organization.get('name'),
      }
    }]);

    UserVoice.push(['addTrigger', '#feedback-button', {
      mode: 'contact'
    }]);
  }, 500);
};
