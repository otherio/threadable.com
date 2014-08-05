Threadable.ConversationDetails = RL.Model.extend({
  id:                RL.attr('number'),
  slug:              RL.attr('string'),
  recipientIds:      RL.attr('array'),
  muterIds:          RL.attr('array'),
  followerIds:       RL.attr('array'),

  recipients: function() {
    return this.findMembers(this.get('muterIds'));
  }.property('recipientIds','organization.members'),

  muters: function() {
    return this.findMembers(this.get('muterIds'));
  }.property('muterIds','organization.members'),

  followers: function() {
    return this.findMembers(this.get('followerIds'));
  }.property('followerIds','organization.members'),

  findMembers: function(memberIds) {
    var members = this.get('organization.members');
    if (typeof members === 'undefined') throw new Error('no members. did you forget to set organization?');
    if (!memberIds) return [];
    return members.filter(function(member) {
      return memberIds.indexOf(member.get('id')) > -1;
    }).sortBy('name');
  }
});

Threadable.RESTAdapter.map("Threadable.ConversationDetails", {
  primaryKey: "slug"
});

Threadable.ConversationDetails.reopen(Threadable.AddOrganizationIdToRequestsMixin);
