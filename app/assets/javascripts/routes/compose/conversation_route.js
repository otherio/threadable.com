//= require ../compose_route

Covered.ComposeConversationRoute = Covered.ComposeRoute.extend({

});

//   // target: 'conversation',

//   // beforeModel: function() {
//   //   this.controllerFor('application').set('composing', this.target);
//   // },

//   // model: function() {
//   //   // if there's an existing compose model, use it.
//   //   var model = this.controllerFor('compose').get('model');
//   //   var organization = this.modelFor('organization');
//   //   if(!model || !model.get('isDirty')) {
//   //     model = Covered.Message.create();
//   //   }
//   //   return model;
//   // },

//   // renderTemplate: function(controller, model) {
//   //   this.controllerFor('organization').set('focus','conversation');

//   //   this.render('compose', {
//   //     outlet: 'conversationPane',
//   //     into: 'organization',
//   //     controller: 'compose'
//   //   });
//   // },

//   // actions: {
//   //   willTransition: function(transition) {

//   //     // var target = transition.targetName;
//   //     // if(target == 'compose_task' || target == 'compose_conversation') {
//   //     //   return;
//   //     // }

//   //     // this.controllerFor('compose').set('composing', null);
//   //     // var model = this.get('currentModel');
//   //     // if (model.get("isDirty") && !model.get("isSaving")) {
//   //     //   model.set('subject', null);
//   //     //   model.set('body', null);
//   //     // }
//   //   }
//   // },

//   // setupController: function(controller, model) {
//   //   this.controllerFor('compose').set('content', model); // route & controller have different names, so this is not automatic
//   //   this.controllerFor('compose').set('composing', this.target);
//   // }

// });
