Covered.Organization = RL.Model.extend({
  id:                        RL.attr('number'),
  slug:                      RL.attr('string'),
  param:                     RL.attr('string'),
  name:                      RL.attr('string'),
  shortName:                 RL.attr('string'),
  subjectTag:                RL.attr('string'),
  description:               RL.attr('string'),

  emailAddress:              RL.attr('string'),
  taskEmailAddress:          RL.attr('string'),
  formattedEmailAddress:     RL.attr('string'),
  formattedTaskEmailAddress: RL.attr('string'),

  groups: RL.hasMany('Covered.Group'),

  loadMembers: RL.loadAssociationMethod('members', function(organization){
    return Covered.Member.fetch({
      organization_id: organization.get('slug')
    });
  }),

  otherGroups: function() {
    return this.get('groups').filterBy('currentUserIsAMember', false);
  }.property('groups'),

  myGroups: function() {
    return this.get('groups').filterBy('currentUserIsAMember', true);
  }.property('groups'),

  // myGroups: Ember.computed.filterBy('groups', 'currentUserIsAMember', true)
});

Covered.RESTAdapter.map("Covered.Organization", {
  primaryKey: "slug"
});
