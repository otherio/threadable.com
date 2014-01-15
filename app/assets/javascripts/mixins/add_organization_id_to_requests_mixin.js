Covered.AddOrganizationIdToRequestsMixin = Ember.Mixin.create({
  prepareRequest: function(request){
    var wasJSON = false;
    if (typeof request.data === 'string'){
      wasJSON = true;
      request.data = JSON.parse(request.data);
    }
    request.data = request.data || {};

    request.data.organization_id = request.data.organization_id || this.get('organizationSlug');

    if (wasJSON) request.data = JSON.stringify(request.data);
    return this._super(request);
  }
});
