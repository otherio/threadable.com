define(function(require) {
  var
    Marionette = require('marionette'),
    membersTemplate = require('text!templates/logged_in/index/members.html'),
    memberTemplate = require('text!templates/logged_in/index/members/member.html'),
    emptyTemplate = require('text!templates/logged_in/index/members/empty.html');

  var MemberView = Backbone.Marionette.ItemView.extend({
    template: _.template(memberTemplate),
    tagName: 'li'
  });

  var EmptyView = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({
    itemView: MemberView,
    template: _.template(membersTemplate),
    tagName: 'ol',
    emptyView: EmptyView

  });
});
