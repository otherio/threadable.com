Threadable.ConversationDetail = RL.Model.extend({
  id:                RL.attr('number'),
  slug:              RL.attr('string'),
  recipientIds:      RL.attr('array'),
  muterCount:        RL.attr('number'),
  followerIds:       RL.attr('array'),
  organizationId:    RL.attr('string'),

  recipients: function() {
    return this.findMembers(this.get('recipientIds'));
  }.property('recipientIds','organization.members'),

  followers: function() {
    return this.findMembers(this.get('followerIds'));
  }.property('followerIds','organization.members'),

  findMembers: function(memberIds) {
    var members = this.get('organization.members');
    if (typeof members === 'undefined') throw new Error('no members. did you forget to set organization?');
    if (!memberIds) return [];
    return members.filter(function(member) {
      // for some reason these are strings here.
      return memberIds.indexOf(parseInt(member.get('id'), 10)) > -1;
    }).sortBy('name');
  }
});

Threadable.RESTAdapter.map("Threadable.ConversationDetail", {
  primaryKey: "slug"
});

Threadable.ConversationDetail.reopen(Threadable.AddOrganizationIdToRequestsMixin);
