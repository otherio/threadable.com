Threadable.Organization = RL.Model.extend({
  id:                        RL.attr('number'),
  slug:                      RL.attr('string'),
  param:                     RL.attr('string'),
  name:                      RL.attr('string'),
  shortName:                 RL.attr('string'),
  subjectTag:                RL.attr('string'),
  description:               RL.attr('string'),
  publicSignup:              RL.attr('boolean'),

  emailAddressUsername:      RL.attr('string'),
  emailAddress:              RL.attr('string'),
  taskEmailAddress:          RL.attr('string'),
  formattedEmailAddress:     RL.attr('string'),
  formattedTaskEmailAddress: RL.attr('string'),

  hasHeldMessages:           RL.attr('boolean'),
  trusted:                   RL.attr('boolean'),
  plan:                      RL.attr('string'),

  groups:                    RL.hasMany('Threadable.Group'),
  emailDomains:              RL.hasMany('Threadable.EmailDomain'),
  googleUser:                RL.belongsTo('Threadable.User'),

  canRemoveNonEmptyGroup:    RL.attr('boolean'),
  canBeGoogleUser:           RL.attr('boolean'),
  canChangeSettings:         RL.attr('boolean'),

  isPaid: function() {
    return this.get('plan') == 'paid';
  }.property('plan'),

  loadMembers: RL.loadAssociationMethod('members', function(organization){
    return Threadable.OrganizationMember.fetch({
      organization_id: organization.get('slug')
    }).then(function(organizationMembers) {
      organizationMembers.setEach('organization', organization);
      return organizationMembers;
    });
  }),

  loadEmailDomains: RL.loadAssociationMethod('emailDomains', function(organization){
    return Threadable.EmailDomain.fetch({
      organization_id: organization.get('slug')
    });
  }),

});

Threadable.RESTAdapter.map("Threadable.Organization", {
  primaryKey: "slug"
});
