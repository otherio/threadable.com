//= require jquery
//= require jquery_ujs
//= require jquery.growing-inputs
//= require jquery.sortable
//= require timeago
//= require s
//= require jquery-s
//= require bootstrap
//= require underscore
//= require multify
//= require_tree ./behaviors
//= require_tree ./widgets

$(document).ready(function() {
  // English (Template)
  $.fn.timeago.defaults.lang.prefixes.about = '';

  $('body').timeago();
});


