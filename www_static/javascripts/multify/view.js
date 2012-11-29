Multify.View  = {
  templates: {},

  render: function(name, data) {
    var template = this.templates[name];
    if (typeof template === 'undefined') throw new Error('template '+name+' undefined');
    return template.render(data);
  }
};
