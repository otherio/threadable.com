Covered.CurrentUser = {
  content: null,
  get: function() {
    if (this.content) return this.content;
    return $.getJSON('/api/current_user').then(function(response){
      this.content = response.current_user ? Ember.Object.create(response.current_user) : null;
      return this.content;
    }.bind(this));
  }
};
