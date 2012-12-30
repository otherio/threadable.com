define(function(require) {
  var
    Marionette = require('marionette'),
    projectTemplate = require('text!templates/logged_in/index/projects/project.html'),
    emptyTemplate = require('text!templates/logged_in/index/projects/empty.html');

  var Project = Backbone.Marionette.ItemView.extend({
    template: _.template(projectTemplate),
    tagName: 'li',
  });

  var Empty = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({

    itemView: Project,

    tagName: 'ul',
    className: 'nav nav-tabs nav-stacked',

    emptyView: Empty,

    selectProject: function(selectedProject){
      selectedProject || (selectedProject = this.options.selectedProject);
      this.options.selectedProject = selectedProject;
      if (!selectedProject) return this;
      var view = this.children.find(function(v){ return v.model.get('slug') == selectedProject });
      if (!view) return this;
      view.$el.addClass('active').siblings().removeClass('active');
      return this;
    },

    onRender: function(){
      this.selectProject();
    }
  });
});
