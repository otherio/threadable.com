(function($) {
  $.fn.textWithRefs = function(offset) {
    // this is a fork of $.text()
    var domReferences = {}, text = '';

    this.each(function() {
      var element = this;

      // Get the text from text nodes and CDATA nodes
      if (element.nodeType === 3 || element.nodeType === 4) {
        // the final solution to the whitespace problem
        var value = element.nodeValue.replace(/(\s|\n|\||>)/g, '');
        if(value) {
          text += value;
          domReferences[offset] = element;
        }

        // Traverse everything else, except comment nodes
      } else if (element.nodeType !== 8) {
        var result = $(element.childNodes).textWithRefs(text.length);
        text += result.text;
        domReferences = _.extend(domReferences, result.references);
      }
    });

    return {text: text, references: domReferences};
  };

  $.fn.findDuplicates = function(toCompare) {
    return this.each(function() {
      var element = this;
      var elementWithRefs = $(this).textWithRefs()
      var elementTextArray = elementWithRefs.text.split('').reverse();
      var offsetFromEnd = 0;

      _.each(toCompare, function(compare) {
        var thisOffsetFromEnd;
        var compareTextArray = $(compare).textWithRefs().text.split('').reverse();

        for(thisOffsetFromEnd = 0; thisOffsetFromEnd < elementTextArray.length; thisOffsetFromEnd++) {
          if(elementTextArray[thisOffsetFromEnd] != compareTextArray[thisOffsetFromEnd]) {
            break;
          }
        }

        if(thisOffsetFromEnd > offsetFromEnd) {
          offsetFromEnd = thisOffsetFromEnd;
        }
      });

      // we have the offset.
      var offset = elementTextArray.length - offsetFromEnd;
      var elementRefs = elementWithRefs.references;
      var elementOffsets = _.keys(elementRefs).sort(function(a,b){return a-b});
      var matchIndex = _.indexOf(elementOffsets, String(offset), true);
      var keysToSelect = [];

      if(matchIndex > 0) {
        keysToSelect = elementOffsets.slice(matchIndex);
      } else {
        keysToSelect = elementOffsets;
      }

      $(this).html($(_.values(_.pick(elementWithRefs.references, keysToSelect))).parent());
    });

  };
})(jQuery);
