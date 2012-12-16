define(function(require) {
  var
    Multify = require('Multify'),
    session = require('Session'),
    testResponses = require('spec/helpers/TestResponses');

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
        spyOn(session, 'save');
        var xhr = Multify.login('jared@change.org', 'password');
        var request = mostRecentAjaxRequest();

        request.response(testResponses.login.success);

        expect(request.url).toMatch(/\/users\/sign_in/);
        expect(request.url).toMatch(/email=jared/);
        expect(request.url).toMatch(/password=password/);

        expect(session.save).toHaveBeenCalled();
      });
    });
  });
});
