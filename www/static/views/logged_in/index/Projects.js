define(function(require) {
  var
    Marionette = require('marionette'),
    template = require('text!templates/logged_in/index/projects.html'),
    ListView = require('views/logged_in/index/projects/List'),
    Project  = require('models/Project');

  return Backbone.Marionette.Layout.extend({
    template: _.template(template),

    regions:{
      list: '> ul > li.list'
    },

    onRender: function(){
      this.list.show(new ListView({collection: this.options.projects}))
      this.selectProject(this.options.selectedProject);
      this.$('form').on('submit', this.createNewProject.bind(this));
    },

    selectProject: function(selectedProject){
      this.list.currentView.selectProject(selectedProject);
      return this;
    },

    createNewProject: function(event) {
      event.preventDefault();
      var input = $(event.currentTarget).find('input');
      var project_name = input.val();
      var project = new Project({name: project_name});
      var currentView = this.list.currentView

      input.attr('disabled', true);

      project.save(null,{
        success: function(){
          input.val('').attr('disabled', false);
          currentView.collection.add(project);
          App.router.navigate('/'+project.get('slug'), {trigger:true});
        }
      });
    }

  });

});
