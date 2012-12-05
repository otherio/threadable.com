define(function(require) {
  var
    Multify = require('Multify'),
    session = require('Session');

  describe('Multify', function() {

    it("exists", function(){
      expect(Multify).toBeDefined();
    });

    describe('#setget', function() {
      it("sets and gets", function() {
        Multify.set('foo', 'bar');
        expect(Multify.get('foo')).toEqual('bar');
        expect(Multify.get('baz')).toBe(undefined);
      });

      it("triggers a change:attr event", function() {
        expect(Multify.set('lol', 'poof')).toEqual('poof');
        spyOn(Multify, 'trigger');
        expect(Multify.set('lol', 'mom')).toEqual('mom');
        expect(Multify.trigger).toHaveBeenCalledWith('change:lol', 'mom', 'poof');
        Multify.trigger.reset();
        expect(Multify.set('lol', 'mom')).toEqual('mom');
        expect(Multify.trigger).not.toHaveBeenCalled();
      });
    });

    describe('#logout', function() {
      it("clears the session, and triggers logout", function(){
        spyOn(session, 'clear');
        spyOn(Multify, 'trigger');
        Multify.logout();
        expect(session.clear).toHaveBeenCalled();
        expect(Multify.trigger).toHaveBeenCalledWith('logout');
      });
    });

    describe('#login', function() {
      it("it should xhr to the api server with the username and password", function(){
        console.log('=(',     jQuery.ajaxSettings.xhr);
        xhr = Multify.login('foo@example.com', 'password');
        request = mostRecentAjaxRequest();

        request.response = {
          status: 200,
          responseText: ''
        };

      });
    });

  });
});
