define(function(require) {
  var
    multify = require('Multify'),
    testResponses = require('spec/helpers/TestResponses'),
    User = require('models/User');


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

    describe("#join", function() {
      var saveSpy, userSpy, params, successSpy, failSpy;

      beforeEach(function() {
        saveSpy = spyOn(User.prototype, 'save').andCallThrough();
        userSpy = spyOn(User.prototype, 'initialize').andCallThrough();
        successSpy = jasmine.createSpy();
        failSpy = jasmine.createSpy();

        params = {
          'name': 'Foo Guyerson',
          'email': 'foo@foo.foo',
          'password': 'passfoo'
        };

        multify.join(params, {success: successSpy, fail: failSpy});
      });

      it("sends username, password, and email to the user create api", function() {
        expect(userSpy).toHaveBeenCalledWith(params, {'path': '/users/register'})
        expect(saveSpy).toHaveBeenCalled();
      });

      it("calls the success function after registering successfully", function() {
        mostRecentAjaxRequest().response(testResponses.register.success);
        expect(successSpy).toHaveBeenCalled();
      });

      it("calls the fail function after failing", function() {
        mostRecentAjaxRequest().response(testResponses.register.fail);
        expect(failSpy).toHaveBeenCalled();
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
          type: 'get',
          url: 'http://' + location.host + '/api/users?foo=bar&authentication_token=5b96d907b5aa364e95',
          dataType: 'json',
          magic: true
        });
      });


    });

    describe("#sync", function() {
      var model, options, fakeRequest;

      beforeEach(function() {
        model = {
          path: '/fakemodel',
          modelName: 'fakemodel',
          id: 1,
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
      });

      it("should make the expected request", function() {
        multify.sync('create', model, options);

        expect(multify.request).toHaveBeenCalledWith(
          'POST', '/fakemodel',
          { fakemodel : { json : true } },
          { context : model }
        );
        expect(fakeRequest.done).toHaveBeenCalledWith(options.success);
        expect(fakeRequest.fail).toHaveBeenCalledWith(options.error);
      });

      it("appends the model id for update and delete", function() {
        multify.sync('update', model, options);

        expect(multify.request).toHaveBeenCalledWith(
          'PUT', '/fakemodel/1',
          { fakemodel : { json : true } },
          { context : model }
        );
        expect(fakeRequest.done).toHaveBeenCalledWith(options.success);
        expect(fakeRequest.fail).toHaveBeenCalledWith(options.error);
      });

    });

  });
});
