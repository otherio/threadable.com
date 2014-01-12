Covered.Group = RL.Model.extend({
  id:                        RL.attr('number'),
  organizationSlug:          RL.attr('string'),
  slug:                      RL.attr('string'),
  name:                      RL.attr('string'),
  emailAddressTag:           RL.attr('string'),
  color:                     RL.attr('string'),
  emailAddress:              RL.attr('string'),
  taskEmailAddress:          RL.attr('string'),
  formattedEmailAddress:     RL.attr('string'),
  formattedTaskEmailAddress: RL.attr('string'),
  conversationsCount:        RL.attr('number'),
  currentUserIsAMember:      RL.attr('boolean'),

  badgeStyle: function() {
    return "background-color: "+this.get('color')+";";
  }.property('color')

});

Covered.RESTAdapter.map("Covered.Group", {
  primaryKey: "slug"
});

Covered.Group.reopen(Covered.AddOrganizationIdToRequestsMixin);
