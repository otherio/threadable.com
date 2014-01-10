Ember.Handlebars.helper('json', function(value, options) {
  // if (value.content) value = value.content;

  if (!value.toJSON && value.content && value.content.toJSON) value = value.content;
  if (value.toJSON) value = value.toJSON();
  return JSON.stringify(value);
});
