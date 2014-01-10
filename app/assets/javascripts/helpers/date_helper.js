Ember.Handlebars.helper('date', function(value, options) {
  return moment(value).fromNow();
});
