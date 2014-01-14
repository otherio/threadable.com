RL.Model.reopen({
  prepareRequest: function(request, model){
    return request;
  }
});

Covered.RESTAdapter = RL.RESTAdapter.create({
  namespace: 'api',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

Covered.Client = RL.Client.create({
  adapter: Covered.RESTAdapter
});







/**
  The patches below are pending this pull request:
  https://github.com/endlessinc/ember-restless/pull/45
**/
RL.Model.reopen({
  prepareRequest: function(request, model){
    return request;
  }
});

Covered.RESTAdapter.reopen({
  /**
    Creates and executes an ajax request wrapped in a promise.
    @method request
    @param {RESTless.Model} model model to use to build the request
    @param {Object} [params] Additional ajax params
    @param {Object} [key] optional resource primary key value
    @return {Ember.RSVP.Promise}
   */
  request: function(model, params, key) {
    var adapter = this, serializer = this.serializer;

    return new Ember.RSVP.Promise(function(resolve, reject) {
      params = params || {};
      params.url = adapter.buildUrl(model, key);
      params.dataType = serializer.dataType;
      params.contentType = serializer.contentType;

      if(params.data && params.type !== 'GET') {
        params.data = serializer.prepareData(params.data);
      }

      params = model.prepareRequest(params);

      params.success = function(data, textStatus, jqXHR) {
        Ember.run(null, resolve, data);
      };
      params.error = function(jqXHR, textStatus, errorThrown) {
        var errors = adapter.parseAjaxErrors(jqXHR, textStatus, errorThrown);
        Ember.run(null, reject, errors);
      };

      var ajax = Ember.$.ajax(params);

      // (private) store current ajax request on the model.
      model.set('currentRequest', ajax);
    });
  }

});
/**
  End of patch
**/


/*
  LoadAssociationMethod

  usage:

    App.User = RL.Model.extend({
      loadPosts: RL.loadAssociationMethod('posts', function(user){
        return App.Posts.fetch({users_id: user.get('id')});
      })
    });

    user = App.User.find(1)
    user.loadPosts.then(function(posts) { …; return posts; })
*/
RL.loadAssociationMethod = function(property, fetcher){
  var promiseProperty = 'load'+property.capitalize()+'Promise';
  return function(reload) {
    var
      record = this,
      promise = record.get(promiseProperty);

    if (promise && (!reload && promise.settled)) return promise;

    promise = fetcher(record);

    promise.then(function(records) {
      record.set(property, records);
      promise.settled = true;
    });

    record.set(promiseProperty, promise);
    return promise;
  };
};






















// var get = Ember.get, set = Ember.set;
// var map = Ember.ArrayPolyfills.map;

// DS.CoveredAdapter = DS.ActiveModelAdapter.extend({
//   namespace: 'api',
//   headers: {
//     'Accept': 'application/json',
//     'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
//   },

//   urlFormat: '/organizations/:organization_id/:type',

//   find: function(store, type, id) {
//     return this.ajax(this.buildURL(type.typeKey, {id: id}), 'GET');
//   },

//   findAll: function(store, type, sinceToken) {
//     var query;

//     if (sinceToken) {
//       query = { since: sinceToken };
//     }

//     return this.ajax(this.buildURL(type.typeKey), 'GET', { data: query });
//   },

//   findQuery: function(store, type, query) {
//     return this.ajax(this.buildURL(type.typeKey), 'GET', { data: query });
//   },

//   findMany: function(store, type, ids) {
//     return this.ajax(this.buildURL(type.typeKey), 'GET', { data: { ids: ids } });
//   },

//   findHasMany: function(store, record, url) {
//     var host = get(this, 'host'),
//         id   = get(record, 'id'),
//         type = record.constructor.typeKey;

//     if (host && url.charAt(0) === '/' && url.charAt(1) !== '/') {
//       url = host + url;
//     }

//     return this.ajax(this.urlPrefix(url, this.buildURL(type, {id: id})), 'GET');
//   },

//   findBelongsTo: function(store, record, url) {
//     var id   = get(record, 'id'),
//         type = record.constructor.typeKey;

//     return this.ajax(this.urlPrefix(url, this.buildURL(type, {id: id})), 'GET');
//   },

//   createRecord: function(store, type, record) {
//     var data = {};
//     var serializer = store.serializerFor(type.typeKey);

//     serializer.serializeIntoHash(data, type, record, { includeId: true });
//     return this.ajax(this.buildURL(type.typeKey, {record: record}), "POST", { data: data });
//   },


//   updateRecord: function(store, type, record) {
//     var data = {};
//     var serializer = store.serializerFor(type.typeKey);

//     serializer.serializeIntoHash(data, type, record);

//     var id = get(record, 'id');

//     return this.ajax(this.buildURL(type.typeKey, {id: id, record: record}), "PUT", { data: data });
//   },

//   deleteRecord: function(store, type, record) {
//     var id = get(record, 'id');

//     return this.ajax(this.buildURL(type.typeKey, {id: id, record: record}), "DELETE");
//   },

//   buildURL: function(type, options) {
//     var url = [];

//     if (!options.record) {
//       // this is pretty much universally wrong, but i'll leave the old behavior for now...
//       var id = options.id;

//       var host = get(this, 'host'),
//           prefix = this.urlPrefix();

//       if (type) { url.push(this.pathForType(type)); }
//       if (id) { url.push(id); }

//       if (prefix) { url.unshift(prefix); }

//       url = url.join('/');
//       if (!host && url) { url = '/' + url; }

//       return url;
//     } else {
//       // this is the version that does something we care about
//       var record = options.record;

//       url = '/' + this.urlPrefix() + this.urlFormat;
//       var organization_slug = record.get('organization').get('slug');
//       url = url.replace(':organization_id', organization_slug);
//       url = url.replace(':type', Ember.String.pluralize(type));

//       var conversation = record.get('conversation');
//       if(conversation) {
//         url = url.replace(':conversation_id', conversation.get('slug'));
//       }
//     }


//     return url;
//   }
// });


// Covered.Store = DS.Store.extend({
//   adapter: DS.CoveredAdapter
// });


// Covered.ObjectTransform = DS.Transform.extend({
//   deserialize: function(serialized) {
//     return serialized;
//   },
//   serialize: function(deserialized) {
//     return deserialized;
//   }
// });
