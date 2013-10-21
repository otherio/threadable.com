//= require modernizr

whenReady = function(callback) {
  whenReady.callbacks.push(callback);
};
whenReady.callbacks = [];

!function() {

  yepnope({
    load: ENV.application_js_url,
    callback: function(){
      unpreventEverything();
      Covered.initialize(ENV);
      var whenReady_callbacks = whenReady.callbacks;
      whenReady = $;
      whenReady_callbacks.forEach($);
    }
  });

  // this prevents link clicks and form submissions before out JS is loaded

  preventEverything = function(){
    bind('click',  preventDefault);
    bind('submit', preventDefault);
  };

  function unpreventEverything(){
    unbind('click',  preventDefault);
    unbind('submit', preventDefault);
  };

  function preventDefault(event) {
    if (!event) return;
    if (event.preventDefault){
      event.preventDefault();
    }else{
      event.returnValue = false;
    }
  }

  function bind(type, handler){
    document.body.addEventListener ?
      document.body.addEventListener(type, handler, false) :
      document.body.attachEvent('on'+type, handler);
  }

  function unbind(type, handler){
    document.body.addEventListener ?
      document.body.removeEventListener(type, handler, false) :
      document.body.detachEvent('on'+type, handler);
  }

}();


// Google analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', ENV.google_analytics_tracking_id, 'covered.io');
ga('send', 'pageview');
