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


Threadable.deferReadiness();

$(window).load(function() {
  $('.page-loading').remove();
  Threadable.advanceReadiness();
});

// Ember.onerror = function(error){
//   var notice = $('<div>');
//   notice.text('ERROR: '+error.message);
//   notice.css({color: 'red'});
//   $('body').prepend(notice);
//   console.error(error);
// };

Ember.TextField.reopen({
  attributeBindings: ['autofocus', 'required']
});



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

Threadable.htmlEscape = function (str) {
    return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
}
