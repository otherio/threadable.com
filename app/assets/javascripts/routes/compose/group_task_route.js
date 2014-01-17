//= require ./task_route

Covered.ComposeGroupTaskRoute = Covered.ComposeTaskRoute.extend({

  groups: function(){
    return [this.modelFor('group')];
  }

});
