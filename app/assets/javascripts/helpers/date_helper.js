Ember.Handlebars.helper('date', function(value, options) {
  // TODO we should emit a time element that is updated over time
  return moment(value).fromNow();
});
