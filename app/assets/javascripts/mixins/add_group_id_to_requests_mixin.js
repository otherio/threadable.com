Threadable.AddGroupIdToRequestsMixin = Ember.Mixin.create({
  prepareRequest: function(request){
    var wasJSON = false;
    if (typeof request.data === 'string'){
      wasJSON = true;
      request.data = JSON.parse(request.data);
    }
    request.data = request.data || {};

    request.data.group_id = (
      request.data.group_id ||
      this.get('groupSlug') ||
      this.get('group.slug')
    );

    if (wasJSON) request.data = JSON.stringify(request.data);
    return this._super(request);
  }
});
