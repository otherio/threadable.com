Threadable.setupDocent = function(currentUser, organization) {
  Ember.run.later(function() {
    docent.setup({
      uid:  Threadable.currentUser.get('id'),
      plan: organization.get('plan'),
      role: organization.get('members').findBy('userId', currentUser.get('userId')).get('role')
    });
  }, 50);
};
