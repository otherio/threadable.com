Multify.Views.Dashboard = Backbone.View.extend({

  className: 'dashboard',

  initialize: function(){
    Multify.router.on("route:project", this.selectProject.bind(this));
  },

  render: function(){


    var html = Multify.render('dashboard');
    this.$el.html(html);

    this.renderProjectsList();
    this.renderProjectsPanel();

    return this;
  },


  renderProjectsList: function(){
    var
      view = this;

    this.main_project_list = new Multify.Views.MainProjectList({
      el: view.$('.main-project-list'),
      projects: this.options.current_user.projects
    });

    this.options.current_user.projects.fetch();
  },

  renderProjectsPanel: function(project){
    this.project_panel = new Multify.Views.Dashboard.ProjectPanel({
      project: project
    });
    this.$('.panels > .main').html(this.project_panel.render().el);
  },

  selectProject: function(project_slug){
    if (!Multify.logged_in) return;
    var project = this.options.current_user.projects.find(function(project){
      return project.get('slug') == project_slug;
    });
    console.log('SELECTING PROJECT', project_slug, project);
    this.renderProjectsPanel(project);
    this.main_project_list.setActiveLink();
  }

});
