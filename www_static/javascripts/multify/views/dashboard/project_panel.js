Multify.Views.Dashboard.ProjectPanel = Backbone.View.extend({

  className: 'dashboard-project-panel',

  initialize: function(){
    // this.options.project.on('all', this.render.bind(this));
  },

  render: function(){
    if (!this.options.project) return this;
    var view = this, html;

    html = Multify.render('dashboard/project_panel',this.options);

    view.$el.html(html);

    // view.setActiveLink();

    // view.$el.find('input').keydown(function(event){
    //   if (event.which !== 13) return;
    //   var
    //     element = $(this),
    //     project_name = element.val();

    //   element.val('');

    //   Multify.current_user.projects.create({
    //     name: project_name
    //   });
    // });
    return this;
  }
});
