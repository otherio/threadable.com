!function(){

  $.fn.animation = function(name, time, motion){
    var elements = this;
    animation(elements, '','','');
    setTimeout(function() { animation(elements, name, time, motion) });
    return this;
  };

  function animation(elements, name, time, motion){
    elements.css(x = $.extend(
      experimental('animation-name', name),
      experimental('animation-duration', time || 0),
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
