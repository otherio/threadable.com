Covered.ApplicationRoute = Ember.Route.extend({
  // // beforeModel: function() {
  // //   this.controllerFor('navbar').setProperties({
  // //     currentUser:         this.controllerFor('application').get('currentUser'),
  // //     currentOrganization: this.controllerFor('organization').get('model')
  // //   });
  // // }
  // setupController: function(){
  //   var application = this.controllerFor('application');
  //   this.controllerFor('navbar').set('currentUser', application.get('currentUser'));
  // },

  actions: {
    willTransition: function(transition) {
      var transitions = this.controllerFor('application').get('transitions');
      transitions.unshift(transition);
      transitions.length = 2;
    }
  }
});
