describe('jquery.deduplicate', function() {
  describe("$.textWithRefs", function(){
    var element, domReferences;
    beforeEach(function() {
      loadFixture('behaviors/jquery.deduplicate');
      $element = $('.deduplicate');
      domReferences = $element.textWithRefs();
    });

    it("returns the text of the dom node", function() {
      // js has no /s modifier. it's stupid.
      debugger;
      expect(domReferences[0].text).toMatch(/foo bar/);
      expect(domReferences[1].text).toMatch(/baz/);
    });

    it("returns accurate references to dom elements", function() {
      expect($(domReferences[0].element).text()).toMatch(/foo bar/);
      expect($(domReferences[1].element).text()).toMatch(/baz/);
    });
  });



});

