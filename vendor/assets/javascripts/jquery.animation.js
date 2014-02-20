!function(){

  $.fn.animation = function(name, time, motion, callback){
    var elements = this;
    animation(elements, false, false, false);
    setTimeout(function() {
      animation(elements, name, time, motion);
      if (callback) setTimeout(callback.bind(elements), Number(time));
    });

    return this;
  };

  function animation(elements, name, time, motion){
    elements.css(x = $.extend(
      experimental('animation-name', name),
      experimental('animation-duration', (time === false ? false : (time || 0)+'ms')),
      experimental('animation-timing-function', motion || "ease")
    ));
  }

  function experimental(property, value){
    var css = {};
    css['-webkit-'+property] = value;
    css[ '-khtml-'+property] = value;
    css[   '-moz-'+property] = value;
    css[    '-ms-'+property] = value;
    css[     '-o-'+property] = value;
    css[           property] = value;
    return css;
  }

}();
