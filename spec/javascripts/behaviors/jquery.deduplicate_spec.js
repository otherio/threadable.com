describe('jquery.deduplicate', function() {
  var element;
  beforeEach(function() {
    loadFixture('behaviors/jquery.deduplicate');
    $element = $('.message1');
  });

  describe("$.textWithRefs", function(){
    it("returns text with no whitespace or quote characters", function() {
      expect($element.textWithRefs().text).toEqual('foobarbaz');
    });

    it("returns accurate references to dom elements", function() {
      var domReferences = $element.textWithRefs().references;
      expect(_.keys(domReferences)).toEqual(['0','3','6']);
      expect($(domReferences['3']).text()).toMatch(/bar/);
    });
  });

  describe("$.findDuplicates", function() {
    var secondElement;
    beforeEach(function() {
      $secondElement = $('.message2');
    });

    it("returns the dom nodes that are not duplicated at the end", function() {
      var $newContent = $secondElement.findDuplicates($element);
      debugger
      expect($newContent.text()).not.toMatch(/unique things/);
      expect($newContent.text()).toMatch(/bar/);
    });
  });

});

