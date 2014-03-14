$.easing.easeInOutQuad = $.easing.easeInOutQuad || function (x, t, b, c, d) {
  if ((t/=d/2) < 1) return c/2*t*t + b;
  return -c/2 * ((--t)*(t-2) - 1) + b;
};

function scrollToElement(element, animated) {
  var scrollTop, duration;
  element = typeof element === 'string' ? $('[data-scroll-position="'+element+'"]') : $(element);
  scrollTop = element.offset().top + scrollToElement.offsetY;
  duration = scrollToElement.maxDuration - Math.abs(Math.abs(window.scrollY) - Math.abs(scrollTop));
  if (duration > scrollToElement.maxDuration) duration = scrollToElement.maxDuration;
  if (duration < scrollToElement.minDuration) duration = scrollToElement.minDuration;
  if (animated){
    $('body,html').animate({scrollTop: scrollTop}, duration, 'easeInOutQuad');
  }else{
    window.scrollTo(window.scrollX, scrollTop);
  }
};

scrollToElement.maxDuration = 800;
scrollToElement.minDuration = 200;
scrollToElement.offsetX = 0;
scrollToElement.offsetY = 0;

$(document).on('click', '[data-scroll-to]', function(event) {
  if (event.shiftKey || event.altKey || event.ctrlKey || event.metaKey) return;
  event.preventDefault();
  scrollToElement($(this).attr('data-scroll-to'), true);
  return false;
});
