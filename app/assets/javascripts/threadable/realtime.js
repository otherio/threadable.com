Threadable.realtime.connect = function(currentUser) {
  var userId = currentUser.get('userId');

  if (typeof io != 'undefined' && io !== null) {
    Threadable.realtime.socketIo = io.connect(Threadable.realtime.url + '/?userId=' + userId + '&token=' + Threadable.realtime.token);
  }

  if (Threadable.realtime.socketIo) {
    Threadable.realtime.socketIo.on('connect', function() {
      Threadable.realtime.socketIo.emit('realtime_user_id_connected', { userId: userId });
    });

    Threadable.realtime.socketIo.on('application_update', function(message) {
      // camelize the keys.
      Object.keys(message).map(function(key) {
        var value = message[key];
        delete message[key];
        message[Ember.String.camelize(key)] = value;
      }, this);

      var update = Threadable.ApplicationUpdate.create(message);
      currentUser.get('applicationUpdates').pushObject(update);
    });
  }
};
