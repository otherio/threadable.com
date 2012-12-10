define(function(require) {
  var
    Marionette = require('marionette'),
    projectsTemplate = require('text!templates/logged_in/index/projects.html'),
    projectTemplate = require('text!templates/logged_in/index/projects/project.html'),
    emptyTemplate = require('text!templates/logged_in/index/projects/empty.html');

  var Project = Backbone.Marionette.ItemView.extend({
    template: _.template(projectTemplate),
    tagName: 'li',
    // onRender: function(){
    //   this.$el.attr('data-slug')
    // }
  });


  var Empty = Backbone.Marionette.ItemView.extend({
    template: _.template(emptyTemplate),
  });

  return Marionette.CollectionView.extend({

    itemView: Project,

    tagName: 'ul',
    className: 'nav nav-tabs nav-stacked',

    emptyView: Empty,

    selectProject: function(selectedProject, view){
      selectedProject || (selectedProject = this.options.selectedProject);
      this.options.selectedProject = selectedProject;
      if (!selectedProject) return;
      view = this.children.find(function(v){ return v.model.get('slug') == selectedProject })
      if (!view) return;
      view.$el.addClass('active').siblings().removeClass('active');
    },

    onRender: function(){
      console.log('rendering main projects list');
      this.selectProject();
    }

  });

});
