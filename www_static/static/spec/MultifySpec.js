define(function(require) {
  var
    multify = require('multify'),
    testResponses = require('spec/helpers/TestResponses');

  describe('multify', function() {

    it("exists", function(){
      expect(multify).toBeDefined();
    });

    describe('#setget', function() {
      it("sets and gets", function() {
        multify.set('foo', 'bar');
        expect(multify.get('foo')).toEqual('bar');
        expect(multify.get('baz')).toBe(undefined);
      });

      it("triggers a change:attr event", function() {
        expect(multify.set('lol', 'poof')).toEqual('poof');
        spyOn(multify, 'trigger');
        expect(multify.set('lol', 'mom')).toEqual('mom');
        expect(multify.trigger).toHaveBeenCalledWith('change:lol', 'mom', 'poof');
        multify.trigger.reset();
        expect(multify.set('lol', 'mom')).toEqual('mom');
        expect(multify.trigger).not.toHaveBeenCalled();
      });
    });

    describe('#logout', function() {
      it("clears the session, and triggers logout", function(){
        spyOn(multify.session, 'clear');
        spyOn(multify.session, 'save');
        multify.logout();
        expect(multify.session.clear).toHaveBeenCalled();
        expect(multify.session.save).toHaveBeenCalled();
      });
    });

    describe('#login', function() {
      it("it should xhr to the api server with the username and password", function(){

        spyOn(multify.session, 'save');
        var xhr = multify.login('jared@change.org', 'password');
        var request = mostRecentAjaxRequest();

        request.response(testResponses.login.success);

        expect(request.url).toMatch(/\/users\/sign_in/);
        expect(request.url).toMatch(/email=jared/);
        expect(request.url).toMatch(/password=password/);

        expect(multify.session.save).toHaveBeenCalled();
      });
    });
  });
});
