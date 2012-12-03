V('dashboard/project_list', {

  initialize: function(){
    this.options.projects.on('all', this.render.bind(this));
  },

  render: function(){
    var view = this, html;

    html = Multify.render('dashboard/project_list',{
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

      view.options.projects.create({
        name: project_name
      });
    });
  },

  setActiveLink: function(){
    var slug = location.pathname.match(/\/projects\/([^\/]+)(\/|$)/);
    if (slug === null || !slug[1]) return;
    active = this.$el.find('a[data-slug="'+slug[1]+'"]').parent();
    active.addClass('active').siblings().removeClass('active');
  }
});
