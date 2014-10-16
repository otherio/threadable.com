Threadable.realtime.connect = function(currentUser) {
  var userId = currentUser.get('userId');

  if (typeof io != 'undefined' && io !== null) {
    Threadable.realtime.socketIo = io.connect(realtimeConfig.url + '/?userId=' + userId + '&token=' + realtimeConfig.token);
  }

  if (Threadable.realtime.socketIo) {
    Threadable.realtime.socketIo.on('connect', function() {
      Threadable.realtime.socketIo.emit('realtime_user_id_connected', { userId: userId });

      setInterval(function() {
        Threadable.realtime.socketIo.emit('ping');
      }, 10*1000);
    });

    Threadable.realtime.socketIo.on('application_update', function(message) {
      camelizeKeys = function(toCamelize) {
        if(typeof(toCamelize) !== 'object' || toCamelize === null) {
          return toCamelize;
        }

        Object.keys(toCamelize).map(function(key) {
          var value = toCamelize[key];
          delete toCamelize[key];
          toCamelize[Ember.String.camelize(key)] = camelizeKeys(value);
        }, this);

        return toCamelize;
      };

      message = camelizeKeys(message);

      message.triggered = false;

      var update = Threadable.ApplicationUpdate.create(message);
      currentUser.get('applicationUpdates').pushObject(update);
    });

    Threadable.realtime.socketIo.on('pong', function(message) {
      // do nothing for now. but these do come back.
    });
  }
};
