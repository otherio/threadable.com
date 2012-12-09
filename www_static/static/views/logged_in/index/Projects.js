define(function(require) {
  var
    Marionette = require('marionette'),
    projectsTemplate = require('text!templates/logged_in/index/projects.html'),
    projectTemplate = require('text!templates/logged_in/index/projects/project.html'),
    emptyTemplate = require('text!templates/logged_in/index/projects/empty.html');

  var Project = Backbone.Marionette.ItemView.extend({
    template: _.template(projectTemplate),
    tagName: 'li'
  });


  var Empty = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({
    itemView: Project,
    // template: _.template(projectsTemplate),
    tagName: 'ol',
    emptyView: Empty
  });
});
