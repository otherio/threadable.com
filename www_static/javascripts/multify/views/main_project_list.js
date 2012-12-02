Multify.Views.MainProjectList = Backbone.View.extend({

  initialize: function(){
    this.options.projects.on('all', this.render.bind(this));
  },

  render: function(){
    var view = this, html;

    html = Multify.templates.main_project_list({
      projects: view.options.projects
    });

    view.$el.html(html);

    view.setActiveLink();

    view.$el.find('input').keydown(function(event){
      if (event.which !== 13) return;
      var
        element = $(this),
        project_name = element.val();

      element.val('');

      Multify.current_user.projects.create({
        name: project_name
      });
    });
  },

  setActiveLink: function(){
    active = this.$el.find('a[href="'+location.pathname+'"]').parent();
    active.addClass('active').siblings().removeClass('active');
  }
});
