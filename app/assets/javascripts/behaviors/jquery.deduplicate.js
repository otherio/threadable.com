(function($) {
  $.fn.textWithRefs = function(offset) {
    // this is a fork of $.text()
    var domReferences = {}, text = '';

    this.each(function() {
      var element = this;

      // Get the text from text nodes and CDATA nodes
      if (element.nodeType === 3 || element.nodeType === 4) {
        // the final solution to the whitespace problem
        var value = element.nodeValue.replace(/(\s|\n)/g, '');
        if(value) {
          text += value;
          domReferences[offset] = element;
        }

        // Traverse everything else, except comment nodes
      } else if (element.nodeType !== 8) {
        var result = $(element.childNodes).textWithRefs(text.length);
        text += result[0];
        domReferences = _.extend(domReferences, result[1]);
      }
    });

    return [text, domReferences];
  };

})(jQuery);
