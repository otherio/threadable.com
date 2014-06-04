Threadable.Organization = RL.Model.extend({
  id:                        RL.attr('number'),
  slug:                      RL.attr('string'),
  param:                     RL.attr('string'),
  name:                      RL.attr('string'),
  shortName:                 RL.attr('string'),
  subjectTag:                RL.attr('string'),
  description:               RL.attr('string'),

  emailAddressUsername:      RL.attr('string'),
  emailAddress:              RL.attr('string'),
  taskEmailAddress:          RL.attr('string'),
  formattedEmailAddress:     RL.attr('string'),
  formattedTaskEmailAddress: RL.attr('string'),

  hasHeldMessages:           RL.attr('boolean'),
  trusted:                   RL.attr('boolean'),

  groups:                    RL.hasMany('Threadable.Group'),
  googleUser:                RL.belongsTo('Threadable.User'),

  canRemoveNonEmptyGroup:    RL.attr('boolean'),
  canBeGoogleUser:           RL.attr('boolean'),
  canChangeSettings:         RL.attr('boolean'),

  loadMembers: RL.loadAssociationMethod('members', function(organization){
    return Threadable.OrganizationMember.fetch({
      organization_id: organization.get('slug')
    }).then(function(organizationMembers) {
      organizationMembers.setEach('organization', organization);
      return organizationMembers;
    });
  })
});

Threadable.RESTAdapter.map("Threadable.Organization", {
  primaryKey: "slug"
});
