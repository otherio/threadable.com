Threadable.User = RL.Model.extend({
  id:           RL.attr('string'),
  userId:       RL.attr('number'),
  param:        RL.attr('string'),
  name:         RL.attr('string'),
  emailAddress: RL.attr('string'),
  slug:         RL.attr('string'),
  avatarUrl:    RL.attr('string'),

  removeFromGroup: function(group) {
    var user = this, promise;
    return new Ember.RSVP.Promise(function(resolve, reject) {
      promise = $.ajax({
        type: 'DELETE',
        url: '/api/group_members/'+user.get('id'),
        data: {
          organization_id: group.get('organizationSlug'),
          group_id: group.get('slug'),
        }
      });
      promise.then(resolve);
      promise.fail(reject);
    });
  },

  addToGroup: function(group) {
    var user = this, promise;
    return new Ember.RSVP.Promise(function(resolve, reject) {
      promise = $.ajax({
        type: 'POST',
        url: '/api/group_members/',
        data: {
          organization_id: group.get('organizationSlug'),
          group_id: group.get('slug'),
          user_id: user.get('id'),
        }
      });
      promise.then(function(response) {
        var groupMember = Threadable.GroupMember.createRecord();
        groupMember.deserialize(response.group_member);
        resolve(groupMember);
      });
      promise.fail(reject);
    });
  },

});
