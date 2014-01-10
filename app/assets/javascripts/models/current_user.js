//= require models/member
Covered.CurrentUser = Covered.Member.extend({
  organizations: DS.hasMany('organization', {async: true}),
});
