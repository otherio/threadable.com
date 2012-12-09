define(function(require) {
  var
    Marionette = require('marionette'),
    projectsTemplate = require('text!templates/logged_in/index/projects.html'),
    projectTemplte = require('text!templates/logged_in/index/projects/project.html'),
    emptyTemplte = require('text!templates/logged_in/index/projects/empty.html');

  var Project = Backbone.Marionette.ItemView.extend({
    template: _.template(projectTemplte),
    tagName: 'li'
  });


  var Empty = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplte),
  });

  return Marionette.CollectionView.extend({
    itemView: Project,
    // template: _.template(projectsTemplate),
    tagName: 'ol',
    // emptyView: Empty

  });
});
