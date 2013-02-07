;(function($){
  var
    STYLES =
     'font-size\
      font-family\
      padding-top\
      padding-left\
      padding-bottom\
      padding-right\
      border-top-style\
      border-left-style\
      border-bottom-style\
      border-right-style\
      border-top-width\
      border-left-width\
      border-bottom-width\
      border-right-width\
      word-spacing\
      letter-spacing\
      line-height\
      text-indent\
      text-transform'.split(/\s+/),
    // keycode that create charactors
    // http://www.cambiaresearch.com/c4/702b8cd1-e5b0-42e6-83ac-25f0306e3e25/javascript-char-codes-key-codes.aspx
    CHAR_CODES = [
      32, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
      75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 186,
      187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
      210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222
    ];

  function getHiddenFor(input) {
    var hidden = input.data('hidden'), styles;
    if (hidden) return hidden;
    styles = {
      'position'         : 'absolute',
      'top'              : '-99999px',
      'left'             : '-9999px',
      'background-color' : 'orange'
    };
    $.each(STYLES, function(i, style) { styles[style] = input.css(style); });
    hidden = $('<span/>').css(styles).insertAfter(input);
    input.data('hidden', hidden);
    return hidden;
  };

  function fixupValue(value, singleline){
    if (value === '' || value.charAt(value.length-1) === "\n") value = value+'.';
    if (!singleline) value = value+'\n.';
    return value;
  }



  $(document)
    // horiontal growth only
    .delegate('input[type="text"][growing], input[type="password"][growing], textarea[growing="x"]', 'keydown keyup change grow', function(event, data) {
      var
        input = $(this),
        value = input.val() || '.';
      if(typeof data !== 'object') data = {}

      if (input.attr('growing') === 'y'){
        input.removeAttr('growing');
        return;
      };

      if (value === input.data('previous_value') && !data.force) return;
      input.data('previous_value', value);

      var hidden = getHiddenFor(input);
      input.width( hidden.css({display:'inline'}).text(value).width() + hidden.text('Mi').width() );
      hidden.html('');
    })

    // vertical growth only
    .delegate('textarea[growing="y"]', 'keydown keyup change grow', function(event, data) {
      var
        input = $(this),
        value = input.val(),
        hidden,
        height;
      if(typeof data !== 'object') data = {}

      if (value === input.data('previous_value') && !data.force) return;
      input.data('previous_value', value);

      value = fixupValue(value, input.data('singleline'));

      hidden = getHiddenFor(input);
      hidden.css({
        display       : 'block',
        'white-space' : 'pre-wrap',
        'word-wrap'   : 'break-word',
        width         : input.width()
      }).text(value);

      height = hidden.height();

      input.css({
        height: height,
        overflow: 'hidden'
      });
    })

    // growth in both directions
    .delegate('textarea[growing=""], textarea[growing="growing"]', 'keydown keyup change grow', function(event, data) {
      var
        input = $(this),
        value = input.val(),
        hidden;
      if(typeof data !== 'object') data = {}

      if (event.type === 'keydown' && CHAR_CODES.indexOf(event.which) !== -1) value = value + '.';

      if (value === input.data('previous_value') && !data.force) return;
      input.data('previous_value', value);

      value = fixupValue(value);

      hidden = getHiddenFor(input);
      var span = hidden.find('span');
      if (span.length === 0) span = hidden.html('<span/>').find('span');

      hidden.css({
        position      : 'static',
        display       : 'block',
        'padding-right': '.25em'
      });
      span.css({
        'white-space' : 'pre-wrap',
        background: 'purple'
      });

      span.text('.');
      var extra_width = span.width();
      var min_height  = hidden.height();

      span.text(value);
      var new_height = hidden.height();

      input.css({
        overflow: 'hidden',
        height: new_height < min_height ? min_height : new_height,
        width:  span.width() + extra_width
      });

      hidden.css({position : 'absolute'});
    });
  ;

})(jQuery);
