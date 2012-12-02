Multify.Views.Dashboard.Tasks = Backbone.View.extend({

  className: 'dashboard-settings',

  initialize: function(){
    this.options.tasks = this.options.project.tasks;
    this.options.tasks.on('all', this.render.bind(this));
  },

  render: function(){

    if (this.options.tasks.isEmpty()){
      this.options.tasks.fetch();
      return this
    }

    var html = Multify.render('dashboard/tasks', this.options);

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
