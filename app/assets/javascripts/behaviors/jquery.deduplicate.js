(function($) {
  $.fn.textWithRefs = function() {
    var textLines = [];

    this.each(function() {
      var element = this;
      // Get the text from text nodes and CDATA nodes
      if (element.nodeType === 3 || element.nodeType === 4) {
        textLines.push({ text: element.nodeValue, reference: element });
        debugger

        console.log('inner', textLines);

        // Traverse everything else, except comment nodes
      } else if (element.nodeType !== 8) {
        textLines = textLines.concat($(element.childNodes).textWithRefs());

        console.log('outer', textLines);

      }
    });

    console.log('done', textLines);


    return textLines;
  };

})(jQuery);
