//= require_self
//= require ./store
//= require_tree ./threadable
//= require_tree ./mixins
//= require_tree ./models
//= require_tree ./controllers
//= require_tree ./views
//= require_tree ./helpers
//= require_tree ./components
//= require_tree ./components
//= require_tree ./templates
//= require ./router
//= require_tree ./routes

$.ajaxSetup({
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});


Threadable = Ember.Application.create({
  // LOG_MODULE_RESOLVER: true,
  // LOG_ACTIVE_GENERATION: true,
  // LOG_VIEW_LOOKUPS: true,
  LOG_TRANSITIONS: true,
  // LOG_TRANSITIONS_INTERNAL: true,
});
// Ember.run.backburner.DEBUG = true;


// Ember.onerror = function(error){
//   var notice = $('<div>');
//   notice.text('ERROR: '+error.message);
//   notice.css({color: 'red'});
//   $('body').prepend(notice);
//   console.error(error);
// };

Ember.TextField.reopen({
  attributeBindings: ['autofocus']
});

UserVoice=window.UserVoice||[];(function(){var uv=document.createElement('script');uv.type='text/javascript';uv.async=true;uv.src='//widget.uservoice.com/MMrElWgvuRBk0LjwGqQ.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(uv,s)})();

// This disables all css-transitions while resizing
$(window).on('resize', function(){
  $('body').addClass('disable-all-transitions');
  var timeout = $(this).data('disableAllTransitionsTimeout');
  clearTimeout(timeout);
  timeout = setTimeout(function(){ $('body').removeClass('disable-all-transitions'); }, 100);
  $(this).data('disableAllTransitionsTimeout', timeout);
});


String.prototype.includes = function(string) {
  return this.indexOf(string) !== -1;
};

// google analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', ENV.google_analytics_tracking_id, 'threadable.com');
ga('send', 'pageview');

