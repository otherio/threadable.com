Multify.Views.Dashboard = Backbone.View.extend({

  className: 'dashboard',

  initialize: function(){
    Multify.router.on("route:project", this.selectProject.bind(this));
  },

  render: function(){


    var html = Multify.templates.dashboard();
    this.$el.html(html);

    this.renderMainProjectsList();
    this.renderMainProjectsPanel();

    return this;
  },


  renderMainProjectsList: function(){
    var
      view = this;

    this.main_project_list = new Multify.Views.MainProjectList({
      el: view.$('.main-project-list'),
      projects: this.options.current_user.projects
    });

    this.options.current_user.projects.fetch();
  },

  renderMainProjectsPanel: function(project){
    this.main_project_panel = new Multify.Views.MainProjectPanel({
      project: project
    });
    this.main_project_panel.render();
    this.$('.panels > .main').html(this.main_project_panel.el);
  },

  selectProject: function(project_slug){
    if (!Multify.logged_in) return;
    var project = this.options.current_user.projects.find(function(project){
      return project.get('slug') == project_slug;
    });
    console.log('SELECTING PROJECT', project_slug, project);
    this.renderMainProjectsPanel(project);
    this.main_project_list.setActiveLink();
  }

});
