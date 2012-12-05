define(function(require) {
  var
    NavView = require('views/NavView'),
    template = require('text!templates/nav.html');

  describe('NavView', function() {

    it("exists", function(){
      expect(NavView).toBeDefined();
    });

    describe("#template", function(){

      it("should be templates/nav.html", function(){
        expect(new NavView().template.source).toEqual(_.template(template).source);
      });

    });

    describe("#templateHelpers", function(){

      it("should return #options", function(){
        var view = new NavView;
        expect(view.templateHelpers()).toBe(view.options);
      });

    });

  });

});
