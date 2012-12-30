define(function(require) {
  var
    session = require('session'),
    Backbone = require('backbone');

  describe('session', function() {

    beforeEach(function(){
      session.clear();
    });

    it("exists", function(){
      expect(session).toBeDefined();
    });

    it("is a singleton", function() {
      expect(session instanceof Backbone.Model).toBeTruthy();
    });

    it("saves to a cookie", function() {
      $.cookie(session.cookieName, null);
      session.set('current_user_id', 42);
      session.save();
      expect($.cookie(session.cookieName)).toBe('{"current_user_id":42}');

      session.set('yourFace', 'my mom');
      session.save();
      expect($.cookie(session.cookieName)).toBe('{"current_user_id":42,"yourFace":"my mom"}');
    });

    it("fetches from a cookie", function() {
      $.cookie(session.cookieName, '{"current_user_id":99,"yourFace":"your dog"}');
      session.fetch();
      expect(session.toJSON()).toEqual({current_user_id:99,yourFace:"your dog"});
      expect(session.get('current_user_id')).toEqual(99);
    });

  });
});
