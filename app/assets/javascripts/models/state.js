Covered.State = DS.Model.extend({
  currentUser: DS.belongsTo('user', {async: true})
});
