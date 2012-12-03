V('dashboard/project_panel', {

  className: 'dashboard-project-panel',

  initialize: function(){
    // this.options.project.on('all', this.render.bind(this));
  },

  render: function(){
    var html = Multify.render('dashboard/project_panel',{
      slug: this.options.project.get('slug')
    });

    this.$el.html(html);

    return this;
  },

  selectTab: function(tab){
    var
      link = this.$('> .nav-tabs a[name="'+tab+'"]'),
      content = this.$('> .tab-content > .tab-pane[name="'+tab+'"]');

    link.parent().addClass('active').siblings().removeClass('active');
    content.addClass('active').siblings().removeClass('active');

    if (this[tab] === undefined){
      this[tab] = new V('dashboard/'+tab, {
        el: content,
        project: this.options.project
      }).render();
    }

    return this;
  }
});
