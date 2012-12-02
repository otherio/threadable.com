Multify.Views.MainProjectPanel = Backbone.View.extend({

  className: 'main-project-panel',

  initialize: function(){
    // this.options.project.on('all', this.render.bind(this));
  },

  render: function(){
    var view = this, html;

    html = Multify.templates.main_project_panel(this.options);

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
  }
});
