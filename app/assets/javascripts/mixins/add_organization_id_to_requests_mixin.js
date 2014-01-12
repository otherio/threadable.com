Covered.AddOrganizationIdToRequestsMixin = Ember.Mixin.create({
  prepareRequest: function(request){
    request.data = request.data || {};
    request.data.organization_id = request.data.organization_id || this.get('organizationSlug');
    return this._super(request);
  }
});
