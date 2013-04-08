describe('jquery.deduplicate', function() {
  describe("$.textWithRefs", function(){
    var element;
    beforeEach(function() {
      loadFixture('behaviors/jquery.deduplicate');
      $element = $('.deduplicate');
    });

    it("returns the text of the dom node", function() {
      // js has no /s modifier. it's stupid.
      expect($element.textWithRefs()[0]).toEqual('foobarbaz');
    });

    it("returns accurate references to dom elements", function() {
      var domReferences = $element.textWithRefs()[1];
      expect(_.keys(domReferences)).toEqual(['0','3','6']);
      expect($(domReferences['3']).text()).toMatch(/bar/);
    });
  });

});

