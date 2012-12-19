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


    describe("#request", function() {
      it("should make an ajax request to the api server", function() {
        var params, options, expectedReturnValue, returnValue;
        params = {foo:'bar'};
        options = {magic: true};
        expectedReturnValue = 82;

        spyOn($, "ajax").andReturn(expectedReturnValue);
        spyOn(multify.session, "get").andReturn('5b96d907b5aa364e95');

        returnValue = multify.request('get', 'users', params, options);

        expect(returnValue).toEqual(expectedReturnValue)

        expect($.ajax).toHaveBeenCalledWith({
          url: 'http://0.0.0.0:9292/users?foo=bar&_method=get&authentication_token=5b96d907b5aa364e95',
          dataType: 'json',
          timeout: 2000,
          magic: true
        });
      });


    });

    describe("#sync", function() {
      it("should make the expected request", function() {
        var model, options, fakeRequest;

        model = {
          path: '/fakemodel',
          modelName: 'fakemodel',
          toJSON: function(){
            return {json:true};
          }
        };

        options = {
          success: function(){},
          error: function(){}
        };

        fakeRequest = jasmine.createSpyObj('multify.request',['done','fail']);
        fakeRequest.done.andReturn(fakeRequest);

        spyOn(multify, "request").andReturn(fakeRequest);

        multify.sync('create', model, options);

        expect(multify.request).toHaveBeenCalledWith(
          'POST', '/fakemodel',
          { fakemodel : { json : true } },
          { context : model }
        );
        expect(fakeRequest.done).toHaveBeenCalledWith(options.success);
        expect(fakeRequest.fail).toHaveBeenCalledWith(options.error);
      });

    });

  });
});
