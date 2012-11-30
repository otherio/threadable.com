Multify.Models.User

var User = Backbone.Model.extend({
  defaults: {
    "name":  null,
    "email": null,
  }
});


var Users = Backbone.Collection.extend({
  model: User
});



// new Users([
//   new User({name:'Jared Grippe', email:'jared@change.org'}),
//   new User({name:'Thomas Shafer', email:'thomas@change.org'}),
//   new User({name:'Mark Dimas', email:'mark@change.org'})
// ]);
