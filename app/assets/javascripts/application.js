//= require jquery
//= require preload_current_user
//= require uikit
//= require sortable
//= require notify
//= require moment
//= require storage
//= require handlebars
//= require ember
//= require ember-restless
//= require_self
//= require covered
//= require debug

$.ajaxSetup({
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});


Covered = Ember.Application.create({
  // LOG_MODULE_RESOLVER: true,
  // LOG_ACTIVE_GENERATION: true,
  // LOG_VIEW_LOOKUPS: true,
  LOG_TRANSITIONS: true,
  // LOG_TRANSITIONS_INTERNAL: true,
});
// Ember.run.backburner.DEBUG = true;

Covered.isSignedIn = function(){
  var currentUser = Covered.currentUser;
  return currentUser && currentUser.get && currentUser.get('isSignedIn');
};

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

$(document).on('click', 'a[href=""]', function(e){ e.preventDefault(); });

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
