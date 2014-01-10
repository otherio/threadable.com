Covered.User = Covered.Member.extend({
  organizations: DS.hasMany('organization', {async: true}),
});

Covered.UserAdapter = DS.CoveredAdapter.extend({
  urlFormat: '/users/:id'
});
