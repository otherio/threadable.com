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
        // jasmine.Ajax doesn't do jsonp.  :(
        //
        // TODO: make this return success on the promise so that it's possble to test
        //       the login process all the way through to session.save()
        var fakeDeferred = $.Deferred();
        spyOn($, 'ajax').andCallFake( function(params) {
          return fakeDeferred;
        });

        var xhr = Multify.login('foo@example.com', 'password');

        expect($.ajax.mostRecentCall.args[0].url).toMatch(/\/users\/sign_in/);
        expect($.ajax.mostRecentCall.args[0].url).toMatch(/email=foo/);
        expect($.ajax.mostRecentCall.args[0].url).toMatch(/password=password/);
      });
    });
  });
});
