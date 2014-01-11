Covered.RESTAdapter = RL.RESTAdapter.create({
  namespace: 'api',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  },
});

Covered.Client = RL.Client.create({
  adapter: Covered.RESTAdapter
});
























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
