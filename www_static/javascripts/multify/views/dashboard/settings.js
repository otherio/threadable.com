Multify.Views.Dashboard.Settings = Backbone.View.extend({

  className: 'dashboard-settings',

  initialize: function(){
    // this.options.project.on('all', this.render.bind(this));
  },

  render: function(){
    var html = Multify.render('dashboard/settings', this.options);

    this.$el.html(html);

    this.$('button.delete').click(function(){
      if (!confirm(this.warning())) return;
      this.options.project.destroy();

      var slug = Multify.current_user.projects.first().get('slug');
      Multify.router.navigate('/projects/'+slug+'/tasks', {trigger: true});
    }.bind(this));

    return this;
  },

  warning: function(){
    return 'Are you sure you want to delete the "'+this.options.project.get('name')+'" project?'
  }

});
