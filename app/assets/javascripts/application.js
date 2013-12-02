//= require jquery
//= require jquery_ujs
//= require_self
//= require rails_widgets
//= require jquery.rails_widgets
//= require jquery.growing-inputs
//= require jquery.sortable
//= require jquery.animation
//= require timeago
//= require bootstrap
//= require bootstrap-wysihtml5
//= require uservoice

//= require covered
//= require_tree ./behaviors
//= require_tree ./widgets
//= require logged_in_init
//= require mixpanel


Object.extend = function(object, extension){
  if (typeof extension === 'undefined') throw new Error('extension is undefined');
  for(var p in extension) object[p] = extension[p];
  return object;
};

// i can't believe this isn't already here.
// thank you, stackoverflow.
RegExp.quote = function(str) {
  return str.toString().replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1");
};


// $(document).ready(function() {
//   // English (Template)
//   $.fn.timeago.defaults.lang.prefixes.about = '';

//   $('body').timeago();
// });


$(document).on('click', 'a[href=""], a[href="#"]', function(event){
  event.preventDefault();
});
