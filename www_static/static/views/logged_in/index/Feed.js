define(function(require) {
  var
    Marionette = require('marionette'),
    itemTemplate = require('text!templates/logged_in/index/feed/item.html'),
    emptyTemplate = require('text!templates/logged_in/index/feed/empty.html');

  var Item = Backbone.Marionette.ItemView.extend({
    template: _.template(itemTemplate),
    tagName: 'li'
  });

  var Empty = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({
    itemView: Item,
    // template: _.template(projectsTemplate),
    tagName: 'ol',
    emptyView: Empty

  });
});
