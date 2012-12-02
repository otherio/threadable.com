Multify.Views.Dashboard = Backbone.View.extend({

  className: 'dashboard',

  initialize: function(){
    Multify.router.on("route:project", function(project_slug, tab){
      this.selectProject(project_slug);
      if (tab) this.project_panel.selectTab(tab);
    }.bind(this));
  },

  render: function(){
    var html = Multify.render('dashboard');

    this.$el.html(html);

    this.renderProjectsList();
    this.renderProjectsPanel();

    return this;
  },


  renderProjectsList: function(){
    this.project_list = new Multify.Views.Dashboard.ProjectList({
      el: this.$('.dashboard-project-list'),
      projects: this.options.current_user.projects
    });

    this.options.current_user.projects.fetch();
  },

  renderProjectsPanel: function(project){
    this.project_panel = new Multify.Views.Dashboard.ProjectPanel({
      el: this.$('.dashboard-project-panel'),
      project: project
    });

    this.project_panel.render();
  },

  selectProject: function(project_slug){
    if (!Multify.logged_in) return;
    var project = this.options.current_user.projects.find(function(project){
      return project.get('slug') == project_slug;
    });
    // console.log('SELECTING PROJECT', project_slug, project);
    this.renderProjectsPanel(project);
    this.project_list.setActiveLink();
  },


});
