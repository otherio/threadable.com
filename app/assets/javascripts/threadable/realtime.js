Threadable.realtime.connect = function(currentUser) {
  var userId = currentUser.get('userId');

  if (typeof io != 'undefined' && io !== null) {
    Threadable.realtime.socketIo = io.connect(Threadable.realtime.url + '/?_rtUserId=' + userId + '&_rtToken=' + Threadable.realtime.token);
  }

  if (Threadable.realtime.socketIo) {
    // Give a nice round-trip ACK to our realtime server that we connected.
    Threadable.realtime.socketIo.on('connect', function() {
      Threadable.realtime.socketIo.emit('realtime_user_id_connected', { userId: userId });
    });

    // Queue up all incoming realtime messages.
    Threadable.realtime.socketIo.on('realtime_msg', function(message) {
      // TODO: make the update actually use the message it received.
      var update = Threadable.ApplicationUpdate.create({
        id: 5,
        action: 'foo',
        target: 'bar'
      });
      currentUser.get('applicationUpdates').pushObject(update);
    });
  }
};
