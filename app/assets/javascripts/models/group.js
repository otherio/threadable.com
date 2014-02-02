Covered.Group = RL.Model.extend({
  id:                        RL.attr('number'),
  organizationSlug:          RL.attr('string'),
  slug:                      RL.attr('string'),
  name:                      RL.attr('string'),
  emailAddressTag:           RL.attr('string'),
  subjectTag:                RL.attr('string'),
  color:                     RL.attr('string'),
  autoJoin:                  RL.attr('boolean'),
  emailAddress:              RL.attr('string'),
  taskEmailAddress:          RL.attr('string'),
  formattedEmailAddress:     RL.attr('string'),
  formattedTaskEmailAddress: RL.attr('string'),
  conversationsCount:        RL.attr('number'),
  membersCount:              RL.attr('count'),
  currentUserIsAMember:      RL.attr('boolean'),

  badgeStyle: function() {
    return "background-color: "+this.get('color')+";";
  }.property('color'),

  join: function() {
    return this._takeAction('join');
  },

  leave: function() {
    return this._takeAction('leave');
  },

  loadMembers: RL.loadAssociationMethod('members', function(group){
    return Covered.GroupMember.fetch({
      organization_id: group.get('organizationSlug'),
      group_id: group.get('slug')
    });
  }),

  _takeAction: function(action) {
    if (!action) throw new Error('action is required');
    var group = this, promise;
    return new Ember.RSVP.Promise(function(resolve, reject) {
      promise = $.ajax({
        type: 'POST',
        dataType: 'json',
        url: '/api/groups/'+group.get('slug')+'/'+action,
        data: { organization_id: group.get('organizationSlug') }
      });
      promise.then(function(response) {
        group.deserialize(response.group);
        resolve(group);
      });
      promise.fail(reject);
    });
  },

});

Covered.RESTAdapter.map("Covered.Group", {
  primaryKey: "slug"
});

Covered.Group.reopen(Covered.AddOrganizationIdToRequestsMixin);
