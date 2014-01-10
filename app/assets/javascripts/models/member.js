Covered.Member = DS.Model.extend({
  name:         DS.attr('string'),
  param:        DS.attr('string'),
  emailAddress: DS.attr('string'),
  slug:         DS.attr('string'),
  avatarUrl:    DS.attr('string')
});
