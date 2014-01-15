Covered.GroupComposeRoute = Covered.ComposeRoute.extend({

  groups: function(){
    return [this.modelFor('group')];
  }

});
